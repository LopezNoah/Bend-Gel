import Base
import ./EdgeQLToken.bend as T
import ./EdgeQLLexer.bend as L
import ./EdgeQLParser.bend as P

# Compose the concrete lexer with the token parser. Proofs about canonical
# token streams can import EdgeQLParser without checking the lexer as well.
def lexical_parse_result(result: T.LexResult) -> P.ParseResult:
  match result:
    case T.LexFailed{error}: P.ParseFailed{P.LexFailure{error}}
    case T.Lexed{tokens}: P.parse(tokens)

def parse_source(source: String) -> P.ParseResult:
  lexical_parse_result(L.lex(source))

def lexical_document_result(result: T.LexResult) -> P.DocumentResult:
  match result:
    case T.LexFailed{error}: P.DocumentFailed{P.LexFailure{error}}
    case T.Lexed{tokens}: P.parse_document(tokens)

def parse_document_source(source: String) -> P.DocumentResult:
  lexical_document_result(L.lex(source))
