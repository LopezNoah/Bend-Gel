import Base

type SqlValue is Data:
  SqlNull{}
  SqlInteger{value: String}
  SqlReal{value: String}
  SqlText{value: String}
  SqlBlob{value: String}

type SqlRow is Data:
  SqlRow{values: List<&2, SqlValue>}

def SQLite.open(path: String) -> IO(Result<&1, &1, U32 & String, File>):
  import "./sqlite.c"
  import "./sqlite.js"

def SQLite.execute(connection: File, sql: String) ->
  IO(File & Result<&1, &1, U32 & String, Unit>):
  import "./sqlite.c"
  import "./sqlite.js"

def SQLite.query(connection: File, sql: String) ->
  IO(File & Result<&1, &1, U32 & String, List<&2, SqlRow>>):
  import "./sqlite.c"
  import "./sqlite.js"

def SQLite.close(connection: File) -> IO(Unit):
  import "./sqlite.c"
  import "./sqlite.js"
