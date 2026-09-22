const sqlite_databases = new Map();
let sqlite_next_handle = 1;

function sqlite_text(value) {
  return new TextDecoder().decode(io_bytes(value));
}

function sqlite_error_code(error) {
  return Math.abs(Number(error?.errno ?? 1)) || 1;
}

function sqlite_list(values) {
  let result = { $: "Nil" };
  for (let i = values.length - 1; i >= 0; i -= 1) {
    result = { $: "Con", head: values[i], tail: result };
  }
  return result;
}

function sqlite_value(value) {
  if (value === null || value === undefined) {
    return { $: "SqlNull" };
  }
  if (typeof value === "bigint") {
    return { $: "SqlInteger", value: value.toString() };
  }
  if (typeof value === "number") {
    return Number.isInteger(value)
      ? { $: "SqlInteger", value: String(value) }
      : { $: "SqlReal", value: String(value) };
  }
  if (typeof value === "string") {
    return { $: "SqlText", value };
  }
  if (value instanceof Uint8Array) {
    return { $: "SqlBlob", value: Buffer.from(value).toString("hex") };
  }
  return { $: "SqlText", value: String(value) };
}

function sqlite_rows(rows) {
  return sqlite_list(rows.map((row) => ({
    $: "SqlRow",
    values: sqlite_list(Object.values(row).map(sqlite_value)),
  })));
}

function sqlite_database(path) {
  const filename = sqlite_text(path);
  try {
    const { Database } = require("bun:sqlite");
    return { engine: "bun", value: new Database(filename) };
  } catch (bun_error) {
    const { DatabaseSync } = require("node:sqlite");
    return { engine: "node", value: new DatabaseSync(filename) };
  }
}

function sqlite_open(path) {
  try {
    const database = sqlite_database(path);
    const handle = sqlite_next_handle++;
    sqlite_databases.set(handle, database);
    return io_done(handle);
  } catch (error) {
    return io_fail(sqlite_error_code(error));
  }
}

function sqlite_execute(connection, sql) {
  const database = sqlite_databases.get(connection);
  if (database === undefined) {
    return io_tup(connection, io_fail(21));
  }
  try {
    if (database.engine === "bun") {
      database.value.run(sqlite_text(sql));
    } else {
      database.value.exec(sqlite_text(sql));
    }
    return io_tup(connection, io_done({ $: "Unit" }));
  } catch (error) {
    return io_tup(connection, io_fail(sqlite_error_code(error)));
  }
}

function sqlite_query(connection, sql) {
  const database = sqlite_databases.get(connection);
  if (database === undefined) {
    return io_tup(connection, io_fail(21));
  }
  try {
    const rows = database.engine === "bun"
      ? database.value.query(sqlite_text(sql)).all()
      : database.value.prepare(sqlite_text(sql)).all();
    return io_tup(connection, io_done(sqlite_rows(rows)));
  } catch (error) {
    return io_tup(connection, io_fail(sqlite_error_code(error)));
  }
}

function sqlite_close(connection) {
  const database = sqlite_databases.get(connection);
  if (database !== undefined) {
    try {
      database.value.close();
    } catch (error) {
    }
    sqlite_databases.delete(connection);
  }
  return { $: "Unit" };
}
