#include <dlfcn.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef long long sqlite3_int64;
typedef struct sqlite3 sqlite3;
typedef struct sqlite3_stmt sqlite3_stmt;

typedef int (*sqlite3_open_fn)(const char*, sqlite3**);
typedef int (*sqlite3_close_fn)(sqlite3*);
typedef const char* (*sqlite3_errmsg_fn)(sqlite3*);
typedef int (*sqlite3_exec_fn)(sqlite3*, const char*, int (*)(void*, int, char**, char**), void*, char**);
typedef void (*sqlite3_free_fn)(void*);
typedef int (*sqlite3_prepare_v2_fn)(sqlite3*, const char*, int, sqlite3_stmt**, const char**);
typedef int (*sqlite3_step_fn)(sqlite3_stmt*);
typedef int (*sqlite3_finalize_fn)(sqlite3_stmt*);
typedef int (*sqlite3_column_count_fn)(sqlite3_stmt*);
typedef int (*sqlite3_column_type_fn)(sqlite3_stmt*, int);
typedef const unsigned char* (*sqlite3_column_text_fn)(sqlite3_stmt*, int);
typedef int (*sqlite3_column_bytes_fn)(sqlite3_stmt*, int);
typedef const void* (*sqlite3_column_blob_fn)(sqlite3_stmt*, int);
typedef sqlite3_int64 (*sqlite3_column_int64_fn)(sqlite3_stmt*, int);

typedef struct {
  void* library;
  sqlite3_open_fn open;
  sqlite3_close_fn close;
  sqlite3_errmsg_fn errmsg;
  sqlite3_exec_fn exec;
  sqlite3_free_fn free;
  sqlite3_prepare_v2_fn prepare_v2;
  sqlite3_step_fn step;
  sqlite3_finalize_fn finalize;
  sqlite3_column_count_fn column_count;
  sqlite3_column_type_fn column_type;
  sqlite3_column_text_fn column_text;
  sqlite3_column_bytes_fn column_bytes;
  sqlite3_column_blob_fn column_blob;
  sqlite3_column_int64_fn column_int64;
  int attempted;
} SqliteApi;

#define SQLITE_OK 0
#define SQLITE_ERROR 1
#define SQLITE_NOMEM 7
#define SQLITE_MISUSE 21
#define SQLITE_CANTOPEN 14
#define SQLITE_ROW 100
#define SQLITE_DONE 101
#define SQLITE_INTEGER 1
#define SQLITE_FLOAT 2
#define SQLITE_TEXT 3
#define SQLITE_BLOB 4
#define SQLITE_NULL 5

static SqliteApi sqlite_api;

static int sqlite_load(void) {
  if (sqlite_api.attempted) {
    return sqlite_api.library == NULL ? SQLITE_CANTOPEN : SQLITE_OK;
  }
  sqlite_api.attempted = 1;
#if defined(__APPLE__)
  sqlite_api.library = dlopen("libsqlite3.dylib", RTLD_NOW | RTLD_LOCAL);
#elif defined(__linux__)
  sqlite_api.library = dlopen("libsqlite3.so.0", RTLD_NOW | RTLD_LOCAL);
  if (sqlite_api.library == NULL) {
    sqlite_api.library = dlopen("libsqlite3.so", RTLD_NOW | RTLD_LOCAL);
  }
#else
  sqlite_api.library = dlopen("libsqlite3.so", RTLD_NOW | RTLD_LOCAL);
#endif
  if (sqlite_api.library == NULL) {
    return SQLITE_CANTOPEN;
  }
#define SQLITE_LOAD(name) \
  do { \
    *(void **)(&sqlite_api.name) = dlsym(sqlite_api.library, "sqlite3_" #name); \
    if (sqlite_api.name == NULL) { \
      dlclose(sqlite_api.library); \
      sqlite_api.library = NULL; \
      return SQLITE_ERROR; \
    } \
  } while (0)
  SQLITE_LOAD(open);
  SQLITE_LOAD(close);
  SQLITE_LOAD(errmsg);
  SQLITE_LOAD(exec);
  SQLITE_LOAD(free);
  SQLITE_LOAD(prepare_v2);
  SQLITE_LOAD(step);
  SQLITE_LOAD(finalize);
  SQLITE_LOAD(column_count);
  SQLITE_LOAD(column_type);
  SQLITE_LOAD(column_text);
  SQLITE_LOAD(column_bytes);
  SQLITE_LOAD(column_blob);
  SQLITE_LOAD(column_int64);
#undef SQLITE_LOAD
  return SQLITE_OK;
}

static Term sqlite_fail(Env e, sqlite3* database, int code, const char* fallback) {
  const char* message = fallback;
  if (database != NULL && sqlite_api.errmsg != NULL) {
    message = sqlite_api.errmsg(database);
  }
  return io_fail(e, (u32)code, message);
}

static Term sqlite_value(Env e, sqlite3_stmt* statement, int column) {
  int type = sqlite_api.column_type(statement, column);
  if (type == SQLITE_NULL) {
    return term_pak(CID_SQLNULL, 0);
  }
  if (type == SQLITE_INTEGER) {
    char text[64];
    int size = snprintf(text, sizeof(text), "%lld",
      (long long)sqlite_api.column_int64(statement, column));
    return io_box(e, CID_SQLINTEGER, io_str(e, text, (u64)size));
  }
  if (type == SQLITE_BLOB) {
    int size = sqlite_api.column_bytes(statement, column);
    const unsigned char* bytes = sqlite_api.column_blob(statement, column);
    char* text = malloc((size_t)size * 2 + 1);
    if (text == NULL) {
      return term_pak(CID_SQLNULL, 0);
    }
    for (int i = 0; i < size; i += 1) {
      snprintf(text + i * 2, 3, "%02x", bytes == NULL ? 0 : bytes[i]);
    }
    text[size * 2] = '\0';
    Term value = io_box(e, CID_SQLBLOB, io_str(e, text, (u64)size * 2));
    free(text);
    return value;
  }
  const unsigned char* value = sqlite_api.column_text(statement, column);
  int size = sqlite_api.column_bytes(statement, column);
  const char* text = value == NULL ? "" : (const char*)value;
  return io_box(e, type == SQLITE_FLOAT ? CID_SQLREAL : CID_SQLTEXT,
    io_str(e, text, (u64)size));
}

static Term sqlite_row(Env e, sqlite3_stmt* statement) {
  Term values = term_pak(CID_NIL, 0);
  int count = sqlite_api.column_count(statement);
  for (int column = count - 1; column >= 0; column -= 1) {
    values = io_node(e, CID_CON, sqlite_value(e, statement, column), values);
  }
  return io_box(e, CID_SQLROW, values);
}

#ifdef CID_SQLITE_OPEN

Term sqlite_open_run(Env e, Term* f, IoWork* w) {
  uint64_t size = 0;
  char* path = io_cstr(e, f[0], &size);
  sqlite3* database = NULL;
  int code = sqlite_load();
  if (code == SQLITE_OK && io_nul(path, size)) {
    code = EILSEQ;
  }
  if (code == SQLITE_OK) {
    code = sqlite_api.open(path, &database);
  }
  free(path);
  if (code != SQLITE_OK) {
    Term result = sqlite_fail(e, database, code, "SQLite.open failed");
    if (database != NULL) {
      sqlite_api.close(database);
    }
    return result;
  }
  return io_done(e, io_hand((intptr_t)database));
}

static void __attribute__((constructor)) sqlite_open_use(void) {
  io_eff(CID_SQLITE_OPEN, sqlite_open_run, 0);
}

#endif

#ifdef CID_SQLITE_EXECUTE

Term sqlite_execute_run(Env e, Term* f, IoWork* w) {
  sqlite3* database = (sqlite3*)io_hand_v(f[0]);
  uint64_t size = 0;
  char* sql = io_cstr(e, f[1], &size);
  char* error = NULL;
  int code = io_nul(sql, size) ? EILSEQ
    : sqlite_api.exec(database, sql, NULL, NULL, &error);
  free(sql);
  Term result = code == SQLITE_OK ? io_done(e, term_pak(CID_UNIT, 0))
    : io_fail(e, (u32)code, error == NULL ? "SQLite.execute failed" : error);
  if (error != NULL) {
    sqlite_api.free(error);
  }
  return io_tup(e, io_hand((intptr_t)database), result);
}

static void __attribute__((constructor)) sqlite_execute_use(void) {
  io_eff(CID_SQLITE_EXECUTE, sqlite_execute_run, 0);
}

#endif

#ifdef CID_SQLITE_QUERY

Term sqlite_query_run(Env e, Term* f, IoWork* w) {
  sqlite3* database = (sqlite3*)io_hand_v(f[0]);
  uint64_t size = 0;
  char* sql = io_cstr(e, f[1], &size);
  sqlite3_stmt* statement = NULL;
  const char* tail = NULL;
  int code = io_nul(sql, size) ? EILSEQ
    : sqlite_api.prepare_v2(database, sql, -1, &statement, &tail);
  free(sql);
  if (code != SQLITE_OK) {
    return io_tup(e, io_hand((intptr_t)database),
      sqlite_fail(e, database, code, "SQLite.query prepare failed"));
  }
  uint64_t capacity = 8;
  uint64_t count = 0;
  Term* rows = malloc(sizeof(Term) * capacity);
  if (rows == NULL) {
    sqlite_api.finalize(statement);
    return io_tup(e, io_hand((intptr_t)database),
      sqlite_fail(e, database, SQLITE_NOMEM, "SQLite.query out of memory"));
  }
  while ((code = sqlite_api.step(statement)) == SQLITE_ROW) {
    if (count == capacity) {
      capacity *= 2;
      Term* expanded = realloc(rows, sizeof(Term) * capacity);
      if (expanded == NULL) {
        free(rows);
        sqlite_api.finalize(statement);
        return io_tup(e, io_hand((intptr_t)database),
          sqlite_fail(e, database, SQLITE_NOMEM, "SQLite.query out of memory"));
      }
      rows = expanded;
    }
    rows[count] = sqlite_row(e, statement);
    count += 1;
  }
  sqlite_api.finalize(statement);
  if (code != SQLITE_DONE) {
    free(rows);
    return io_tup(e, io_hand((intptr_t)database),
      sqlite_fail(e, database, code, "SQLite.query step failed"));
  }
  Term result = term_pak(CID_NIL, 0);
  while (count > 0) {
    count -= 1;
    result = io_node(e, CID_CON, rows[count], result);
  }
  free(rows);
  return io_tup(e, io_hand((intptr_t)database), io_done(e, result));
}

static void __attribute__((constructor)) sqlite_query_use(void) {
  io_eff(CID_SQLITE_QUERY, sqlite_query_run, 0);
}

#endif

#ifdef CID_SQLITE_CLOSE

Term sqlite_close_run(Env e, Term* f, IoWork* w) {
  sqlite3* database = (sqlite3*)io_hand_v(f[0]);
  sqlite_api.close(database);
  return term_pak(CID_UNIT, 0);
}

static void __attribute__((constructor)) sqlite_close_use(void) {
  io_eff(CID_SQLITE_CLOSE, sqlite_close_run, 0);
}

#endif
