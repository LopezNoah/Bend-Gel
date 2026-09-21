import Base
import ../src/EdgeQLParser.bend as P
import ../src/EdgeQLSyntax.bend as E

def close_and_return(file_and_result: File & Result<&1, &1, U32 & String, String>) -> IO(String):
  (next_file, result) = file_and_result
  do IO<String>:
    source : String <- IO.pass(String, result)
    File.close(next_file)
    return source

def read_source(path: String) -> IO(String):
  do IO<String>:
    file : File <- IO.try(File, File.open(path, "r"))
    file_and_result : File & Result<&1, &1, U32 & String, String> <- File.read(file, 100000)
    close_and_return(file_and_result)

def has_schema_and_queries(document: E.SurfaceDocument) -> Bool:
  match document:
    case E.Document{statements}:
      match statements:
        case Con{E.SSchema{schema}, Con{E.SSchema{ddl}, Con{E.SQuery{select}, Con{E.SQuery{insert}, Nil{}}}}}:
          True{}
        case _:
          False{}

def check_parse_error(error: P.ParseError) -> IO(Unit):
  match error:
    case P.LexFailure{error}: IO.die(Unit, 2, "EdgeQL fixture failed during lexing")
    case P.UnexpectedEnd{}: IO.die(Unit, 3, "EdgeQL fixture ended unexpectedly")
    case P.UnexpectedToken{token}: IO.die(Unit, 4, "EdgeQL fixture contained an unexpected token")
    case P.ExpectedIdentifier{}: IO.die(Unit, 5, "EdgeQL fixture needed an identifier")
    case P.ExpectedShape{}: IO.die(Unit, 6, "EdgeQL fixture needed a shape")
    case P.UnclosedDelimiter{}: IO.die(Unit, 7, "EdgeQL fixture had an unclosed delimiter")
    case P.ParseStepLimit{}: IO.die(Unit, 8, "EdgeQL fixture exceeded parser fuel")
    case P.DocumentUnclosedDelimiter{}: IO.die(Unit, 9, "EdgeQL document had an unclosed delimiter")

def check_document_shape(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      IO.die(Unit, 1, "EdgeQL fixture did not contain the expected schema and queries")

def check_parse(result: P.DocumentResult) -> IO(Unit):
  match result:
    case P.DocumentParsed{value}:
      check_document_shape(has_schema_and_queries(value))
    case P.DocumentFailed{error}:
      check_parse_error(error)

def main() -> IO(Unit):
  do IO<Unit>:
    source : String <- read_source("tests/fixtures/schema.edgeql")
    result : P.DocumentResult = P.parse_document_source(source)
    check_parse(result)
