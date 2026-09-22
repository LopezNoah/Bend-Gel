import Base
import ../packages/sqlite/main.bend as DB

def execute_ok(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (connection, result) = pair
  do IO<File>:
    IO.pass(Unit, result)
    return connection

def query_ok(pair: File & Result<&1, &1, U32 & String, List<&2, DB.SqlRow>>) ->
  IO(File & List<&2, DB.SqlRow>):
  (connection, result) = pair
  do IO<File & List<&2, DB.SqlRow>>:
    rows : List<&2, DB.SqlRow> <- IO.pass(List<&2, DB.SqlRow>, result)
    return (connection, rows)

def expected_pair(first: List<&2, DB.SqlValue>, second: List<&2, DB.SqlValue>) -> Bool:
  match first second:
    case Con{DB.SqlText{first_name}, Con{DB.SqlInteger{first_count}, Nil{}}}
      Con{DB.SqlText{second_name}, Con{DB.SqlInteger{second_count}, Nil{}}}:
        Bool.and(String.eq(first_name, "Bend"),
          Bool.and(String.eq(first_count, "2"),
            Bool.and(String.eq(second_name, "Gel"), String.eq(second_count, "3"))))
    case _ _:
      False{}

def expected_rows(rows: List<&2, DB.SqlRow>) -> Bool:
  match rows:
    case Con{DB.SqlRow{first}, Con{DB.SqlRow{second}, Nil{}}}:
      expected_pair(first, second)
    case _:
      False{}

def close_checked(ok: Bool, connection: File) -> IO(Unit):
  match ok:
    case True{}:
      DB.SQLite.close(connection)
    case False{}:
      do IO<Unit>:
        DB.SQLite.close(connection)
        IO.die(Unit, 1, "SQLite query returned unexpected rows")

def check_rows(connection_and_rows: File & List<&2, DB.SqlRow>) -> IO(Unit):
  (connection, rows) = connection_and_rows
  close_checked(expected_rows(rows), connection)

def main() -> IO(Unit):
  do IO<Unit>:
    connection : File <- IO.try(File, DB.SQLite.open(":memory:"))
    table_result : File & Result<&1, &1, U32 & String, Unit> <-
      DB.SQLite.execute(connection, "CREATE TABLE items (name TEXT, count INTEGER)")
    after_table : File <- execute_ok(table_result)
    bend_result : File & Result<&1, &1, U32 & String, Unit> <-
      DB.SQLite.execute(after_table, "INSERT INTO items VALUES ('Bend', 2)")
    after_bend : File <- execute_ok(bend_result)
    gel_result : File & Result<&1, &1, U32 & String, Unit> <-
      DB.SQLite.execute(after_bend, "INSERT INTO items VALUES ('Gel', 3)")
    after_gel : File <- execute_ok(gel_result)
    query_result : File & Result<&1, &1, U32 & String, List<&2, DB.SqlRow>> <-
      DB.SQLite.query(after_gel, "SELECT name, count FROM items ORDER BY name")
    rows : File & List<&2, DB.SqlRow> <- query_ok(query_result)
    check_rows(rows)
