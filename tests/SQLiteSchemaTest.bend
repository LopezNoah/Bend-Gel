import Base
import ../src/SQLiteSchema.bend as SQL
import ../packages/sqlite/main.bend as DB

def close_source(file_and_result: File & Result<&1, &1, U32 & String, String>) -> IO(String):
  (file, result) = file_and_result
  do IO<String>:
    source : String <- IO.pass(String, result)
    File.close(file)
    return source

def read_source(path: String) -> IO(String):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    result : File & Result<&1, &1, U32 & String, String> <- File.read(file, 100000)
    close_source(result)

def statements(result: SQL.DDLResult) -> IO(List<&2, String>):
  match result:
    case SQL.DDLReady{statements}: IO.pure(List<&2, String>, statements)
    case SQL.DDLFailed{}: IO.die(List<&2, String>, 1, "Schema-to-SQLite compilation failed")

def execute_checked(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (connection, result) = pair
  do IO<File>:
    IO.pass(Unit, result)
    return connection

def execute_all(statements: List<&2, String>, connection: File) -> IO(File):
  match statements:
    case Nil{}: IO.pure(File, connection)
    case Con{sql, rest}:
      do IO<File>:
        result : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, sql)
        next : File <- execute_checked(result)
        execute_all(rest, next)

def check_sql(statements: List<&2, String>) -> Bool:
  match statements:
    case Con{user, Con{friends, Con{tags, Con{post, Con{audit, Nil{}}}}}}:
      Bool.and(String.eq(user, "CREATE TABLE \"User\" (\"id\" INTEGER PRIMARY KEY, \"name\" TEXT NOT NULL, \"age\" INTEGER, \"active\" INTEGER CHECK (\"active\" IN (0, 1)), \"manager\" INTEGER NOT NULL REFERENCES \"User\"(\"id\"))"),
        Bool.and(String.eq(friends, "CREATE TABLE \"User.friends\" (\"source_id\" INTEGER NOT NULL REFERENCES \"User\"(\"id\") ON DELETE CASCADE, \"target_id\" INTEGER NOT NULL REFERENCES \"User\"(\"id\"), PRIMARY KEY (\"source_id\", \"target_id\"))"),
          Bool.and(String.eq(tags, "CREATE TABLE \"User.tags\" (\"source_id\" INTEGER NOT NULL REFERENCES \"User\"(\"id\") ON DELETE CASCADE, \"value\" TEXT NOT NULL, PRIMARY KEY (\"source_id\", \"value\"))"),
            Bool.and(String.eq(post, "CREATE TABLE \"Post\" (\"id\" INTEGER PRIMARY KEY, \"title\" TEXT NOT NULL, \"author\" INTEGER NOT NULL REFERENCES \"User\"(\"id\"))"),
              String.eq(audit, "CREATE TABLE \"Audit\" (\"id\" INTEGER PRIMARY KEY, \"action\" TEXT NOT NULL)")))))
    case _: False{}

def is_failed(result: SQL.DDLResult) -> Bool:
  match result:
    case SQL.DDLFailed{}: True{}
    case SQL.DDLReady{statements}: False{}

def check_invalid() -> Bool:
  Bool.and(is_failed(SQL.from_source("create type A { property bad -> json; };")),
    Bool.and(is_failed(SQL.from_source("create type A { link missing -> B; };")),
      Bool.and(is_failed(SQL.from_source("create type A { property a -> str { constraint exclusive; }; };")),
        Bool.and(is_failed(SQL.from_source("create type A { property id -> str; };")),
          is_failed(SQL.from_source("create type A { multi link b -> A { property weight -> int64; }; };"))))))

def query_document_result(result: SQL.DDLResult) -> Bool:
  match result:
    case SQL.DDLReady{Con{table, Nil{}}}:
      String.eq(table, "CREATE TABLE \"A\" (\"id\" INTEGER PRIMARY KEY, \"name\" TEXT NOT NULL)")
    case _: False{}

def query_in_document() -> Bool:
  query_document_result(SQL.from_source("create type A { required property name -> str; }; select A;"))

def assert_valid(ok: Bool) -> IO(Unit):
  match ok:
    case True{}: IO.pure(Unit, Unit{})
    case False{}: IO.die(Unit, 1, "Unexpected schema SQL or unsupported syntax was accepted")

def rows_expected(rows: List<&2, DB.SqlRow>) -> Bool:
  match rows:
    case Con{DB.SqlRow{Con{DB.SqlText{friend}, Con{DB.SqlInteger{id}, Nil{}}}}, Nil{}}:
      Bool.and(String.eq(friend, "Grace"), String.eq(id, "1"))
    case _: False{}

def tag_expected(rows: List<&2, DB.SqlRow>) -> Bool:
  match rows:
    case Con{DB.SqlRow{Con{DB.SqlText{tag}, Nil{}}}, Nil{}}: String.eq(tag, "math")
    case _: False{}

def check_rows(pair: File & Result<&1, &1, U32 & String, List<&2, DB.SqlRow>>) -> IO(File):
  (connection, result) = pair
  do IO<File>:
    rows : List<&2, DB.SqlRow> <- IO.pass(List<&2, DB.SqlRow>, result)
    assert_valid(rows_expected(rows))
    return connection

def check_tags(pair: File & Result<&1, &1, U32 & String, List<&2, DB.SqlRow>>) -> IO(File):
  (connection, result) = pair
  do IO<File>:
    rows : List<&2, DB.SqlRow> <- IO.pass(List<&2, DB.SqlRow>, result)
    assert_valid(tag_expected(rows))
    return connection

def expect_rejected(pair: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (connection, result) = pair
  match result:
    case Fail{error}: IO.pure(File, connection)
    case Done{value}: IO.die(File, 1, "SQLite accepted an invalid foreign key or boolean")

def main() -> IO(Unit):
  do IO<Unit>:
    source : String <- read_source("tests/fixtures/sqlite.edgeql")
    +ddl : List<&2, String> <- statements(SQL.from_source(source))
    assert_valid(check_sql(ddl))
    assert_valid(Bool.and(check_invalid(), query_in_document()))
    connection : File <- IO.try(File, DB.SQLite.open(":memory:"))
    enabled : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "PRAGMA foreign_keys = ON")
    connection : File <- execute_checked(enabled)
    connection : File <- execute_all(ddl, connection)
    ada : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "INSERT INTO User (id, name, manager) VALUES (1, 'Ada', 1)")
    connection : File <- execute_checked(ada)
    grace : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "INSERT INTO User (id, name, manager) VALUES (2, 'Grace', 1)")
    connection : File <- execute_checked(grace)
    post : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "INSERT INTO Post (title, author) VALUES ('Hello', 1)")
    connection : File <- execute_checked(post)
    friends : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "INSERT INTO \"User.friends\" VALUES (1, 2)")
    connection : File <- execute_checked(friends)
    tags : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "INSERT INTO \"User.tags\" VALUES (1, 'math')")
    connection : File <- execute_checked(tags)
    bad_friend : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "INSERT INTO \"User.friends\" VALUES (1, 999)")
    connection : File <- expect_rejected(bad_friend)
    bad_bool : File & Result<&1, &1, U32 & String, Unit> <- DB.SQLite.execute(connection, "UPDATE User SET active = 2 WHERE id = 1")
    connection : File <- expect_rejected(bad_bool)
    query : File & Result<&1, &1, U32 & String, List<&2, DB.SqlRow>> <- DB.SQLite.query(connection,
      "SELECT f.name, u.id FROM User u JOIN \"User.friends\" l ON l.source_id = u.id JOIN User f ON f.id = l.target_id")
    connection : File <- check_rows(query)
    tag_query : File & Result<&1, &1, U32 & String, List<&2, DB.SqlRow>> <- DB.SQLite.query(connection,
      "SELECT value FROM \"User.tags\" WHERE source_id = 1")
    connection : File <- check_tags(tag_query)
    DB.SQLite.close(connection)
