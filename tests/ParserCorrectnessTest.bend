import Base
import ../src/EdgeQLToken.bend as T
import ../src/EdgeQLLexer.bend as L
import ../src/EdgeQLSyntax.bend as E
import ../src/EdgeQLParser.bend as P
import ../src/EdgeQLSource.bend as Source

def passed(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{value}: True{}
    case P.ParseFailed{error}: False{}

def failed(result: P.ParseResult) -> Bool:
  Bool.not(passed(result))

def document_failed(result: P.DocumentResult) -> Bool:
  match result:
    case P.DocumentParsed{value}: False{}
    case P.DocumentFailed{error}: True{}

def lexical_failure(result: P.ParseResult) -> Bool:
  match result:
    case P.ParseFailed{P.LexFailure{T.InvalidCharacter{character}}}: True{}
    case _: False{}

def lexical_document_failure(result: P.DocumentResult) -> Bool:
  match result:
    case P.DocumentFailed{P.LexFailure{T.InvalidCharacter{character}}}: True{}
    case _: False{}

def document_has_one_query(result: P.DocumentResult) -> Bool:
  match result:
    case P.DocumentParsed{E.Document{Con{E.SQuery{E.SSelect{E.SLiteral{E.LInt{1n}}, Nil{}, E.SNoFilter{}, E.SNoOrder{}}}, Nil{}}}}: True{}
    case _: False{}

def full_parse() -> Bool:
  ordinary = Bool.and(passed(Source.parse_source("1")), passed(Source.parse_source("1;")))
  extra = Bool.and(failed(Source.parse_source("1;;")), failed(Source.parse_source("1; 2")))
  missing_eof = failed(P.parse(Con{T.TIntLiteral{1n}, Nil{}}))
  after_eof = failed(P.parse(Con{T.TIntLiteral{1n}, Con{T.TEOF{}, Con{T.TIntLiteral{2n}, Nil{}}}}))
  valid_document = Bool.and(document_has_one_query(Source.parse_document_source("select 1;")),
    document_has_one_query(Source.parse_document_source("select 1")))
  document_missing_eof = document_failed(P.parse_document(Con{T.TSelect{}, Con{T.TIntLiteral{1n}, Nil{}}}))
  document_after_eof = document_failed(P.parse_document(Con{T.TSelect{}, Con{T.TIntLiteral{1n}, Con{T.TEOF{}, Con{T.TIntLiteral{2n}, Nil{}}}}}))
  Bool.and(ordinary, Bool.and(extra, Bool.and(missing_eof, Bool.and(after_eof,
    Bool.and(valid_document, Bool.and(document_missing_eof, document_after_eof))))))

def same_success(a: P.ParseResult, b: P.ParseResult) -> Bool:
  match a b:
    case P.Parsed{E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}} P.Parsed{E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}}: True{}
    case _ _: False{}

def same_error(a: P.ParseResult, b: P.ParseResult) -> Bool:
  match a b:
    case P.ParseFailed{P.ExpectedIdentifier{}} P.ParseFailed{P.ExpectedIdentifier{}}: True{}
    case _ _: False{}

def deterministic() -> Bool:
  +ok_tokens = L.tokens("1 + 2")
  +bad_tokens = L.tokens(". +")
  Bool.and(same_success(P.parse(ok_tokens), P.parse(ok_tokens)),
    same_error(P.parse(bad_tokens), P.parse(bad_tokens)))

# A subexpression may stop at a caller-owned FILTER token, but it must hand
# back that token and the remaining suffix in their original order.
def expression_remainder(result: P.ExprResult) -> Bool:
  match result:
    case P.ExprParsed{E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, Con{T.TFilter{}, Con{T.TIntLiteral{3n}, Con{T.TEOF{}, Nil{}}}}}: True{}
    case _: False{}

def monotone_remainder() -> Bool:
  tokens = {[T.TIntLiteral{1n}, T.TPlus{}, T.TIntLiteral{2n}, T.TFilter{}, T.TIntLiteral{3n}, T.TEOF{}] : List<&2, T.Token>}
  expression_remainder(P.parse_expr_go(100000n, P.Scan{tokens, Nil{}, Nil{}}))

def same_token(a: T.Token, b: T.Token) -> Bool:
  match a b:
    case T.TSelect{} T.TSelect{}: True{}
    case T.TWith{} T.TWith{}: True{}
    case T.TFor{} T.TFor{}: True{}
    case T.TIn{} T.TIn{}: True{}
    case T.TUnion{} T.TUnion{}: True{}
    case T.TFilter{} T.TFilter{}: True{}
    case T.TOrder{} T.TOrder{}: True{}
    case T.TBy{} T.TBy{}: True{}
    case T.TAsc{} T.TAsc{}: True{}
    case T.TDesc{} T.TDesc{}: True{}
    case T.TInsert{} T.TInsert{}: True{}
    case T.TUpdate{} T.TUpdate{}: True{}
    case T.TSet{} T.TSet{}: True{}
    case T.TIdentifier{text} T.TIdentifier{other}: String.eq(text, other)
    case T.TStringLiteral{text} T.TStringLiteral{other}: String.eq(text, other)
    case T.TIntLiteral{value} T.TIntLiteral{other}: Nat.is_eq(value, other)
    case T.TDollar{} T.TDollar{}: True{}
    case T.TDot{} T.TDot{}: True{}
    case T.TComma{} T.TComma{}: True{}
    case T.TLBrace{} T.TLBrace{}: True{}
    case T.TRBrace{} T.TRBrace{}: True{}
    case T.TLParen{} T.TLParen{}: True{}
    case T.TRParen{} T.TRParen{}: True{}
    case T.TColon{} T.TColon{}: True{}
    case T.TAssign{} T.TAssign{}: True{}
    case T.TEquals{} T.TEquals{}: True{}
    case T.TPlus{} T.TPlus{}: True{}
    case T.TCoalesce{} T.TCoalesce{}: True{}
    case T.TSemicolon{} T.TSemicolon{}: True{}
    case T.TOther{character} T.TOther{other}: Char.is_eq(character, other)
    case T.TEOF{} T.TEOF{}: True{}
    case _ _: False{}

def same_tokens(xs: List<&2, T.Token>, ys: List<&2, T.Token>) -> Bool:
  match xs ys:
    case Nil{} Nil{}: True{}
    case Con{head, tail} Con{other, rest}:
      Bool.and(same_token(head, other), same_tokens(tail, rest))
    case _ _: False{}

# Suffix identity is stronger than checking that the parser merely returns
# fewer tokens: it also detects reordered or fabricated lookahead tokens.
def is_suffix(tokens: List<&2, T.Token>, +rest: List<&2, T.Token>) -> Bool:
  match tokens:
    case Nil{}:
      match rest:
        case Nil{}: True{}
        case Con{head, tail}: False{}
    case Con{+head, +tail}:
      Bool.or(same_tokens(Con{head, tail}, rest), is_suffix(tail, rest))

def expression_suffix_result(+tokens: List<&2, T.Token>, result: P.ExprResult) -> Bool:
  match result:
    case P.ExprParsed{value, +rest}:
      Bool.and(is_suffix(tokens, rest), Nat.is_lt(List.length(&2, T.Token, rest), List.length(&2, T.Token, tokens)))
    case P.ExprFailed{error}: False{}

def expression_consumes_suffix(+tokens: List<&2, T.Token>) -> Bool:
  expression_suffix_result(tokens, P.parse_expr_go(100000n, P.Scan{tokens, Nil{}, Nil{}}))

def shape_suffix_result(+tokens: List<&2, T.Token>, result: P.ShapeResult) -> Bool:
  match result:
    case P.ShapeParsed{fields, +rest}:
      Bool.and(is_suffix(tokens, rest), Nat.is_lt(List.length(&2, T.Token, rest), List.length(&2, T.Token, tokens)))
    case P.ShapeFailed{error}: False{}

def shape_consumes_suffix(+tokens: List<&2, T.Token>) -> Bool:
  shape_suffix_result(tokens, P.parse_shape_go(100000n, P.ShapeScan{tokens, Nil{}, P.ShapeDone{}}))

def computed_shape_fields(result: P.ShapeResult) -> Bool:
  match result:
    case P.ShapeParsed{Con{E.SShapeComputed{E.Name{"age"}, E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}}, Con{E.SShapeField{E.Name{"name"}}, Nil{}}}, Con{T.TEOF{}, Nil{}}}: True{}
    case _: False{}

def call_shape_field(result: P.ShapeResult) -> Bool:
  match result:
    case P.ShapeParsed{Con{E.SShapeComputed{E.Name{"age"}, E.SCall{E.Name{"add"}, Con{E.SLiteral{E.LInt{1n}}, Con{E.SLiteral{E.LInt{2n}}, Nil{}}}}}, Con{E.SShapeField{E.Name{"name"}}, Nil{}}}, Con{T.TEOF{}, Nil{}}}: True{}
    case _: False{}

def parse_fields(tokens: List<&2, T.Token>) -> P.ShapeResult:
  P.parse_shape_go(100000n, P.ShapeScan{tokens, Nil{}, P.ShapeDone{}})

def insert_with_computed_fields(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SInsert{E.Name{"Movie"}, Con{E.SShapeComputed{E.Name{"age"}, E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}}, Con{E.SShapeComputed{E.Name{"name"}, E.SLiteral{E.LInt{3n}}}, Nil{}}}}}: True{}
    case _: False{}

def expressions_advance() -> Bool:
  literal = expression_consumes_suffix([T.TIntLiteral{1n}, T.TEOF{}])
  operator = expression_consumes_suffix([T.TIntLiteral{1n}, T.TPlus{}, T.TIntLiteral{2n}, T.TFilter{}, T.TIntLiteral{3n}, T.TEOF{}])
  call_expr = expression_consumes_suffix([T.TIdentifier{"add"}, T.TLParen{}, T.TIntLiteral{1n}, T.TComma{}, T.TIntLiteral{2n}, T.TRParen{}, T.TOrder{}, T.TBy{}, T.TIntLiteral{3n}, T.TEOF{}])
  grouped = expression_consumes_suffix([T.TLParen{}, T.TIntLiteral{1n}, T.TUnion{}, T.TIntLiteral{2n}, T.TRParen{}, T.TPlus{}, T.TIntLiteral{1n}, T.TSemicolon{}, T.TEOF{}])
  path = expression_consumes_suffix([T.TIdentifier{"Movie"}, T.TDot{}, T.TIdentifier{"title"}, T.TSet{}, T.TEOF{}])
  Bool.and(literal, Bool.and(operator, Bool.and(call_expr, Bool.and(grouped, path))))

def for_body_consumes_remainder() -> Bool:
  body = {E.SLiteral{E.LInt{2n}} : E.SurfaceExpr}
  source = {E.SLiteral{E.LInt{1n}} : E.SurfaceExpr}
  result = {P.ExprParsed{body, [T.TSemicolon{}, T.TIntLiteral{3n}, T.TEOF{}]} : P.ExprResult}
  failed(P.for_body_result(result, E.Name{"x"}, source))

def precedence(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SUnion{E.SLiteral{E.LInt{1n}}, E.SCoalesce{E.SLiteral{E.LInt{2n}}, E.SEq{E.SLiteral{E.LInt{3n}}, E.SAdd{E.SLiteral{E.LInt{4n}}, E.SLiteral{E.LInt{5n}}}}}}}: True{}
    case _: False{}

def left_associative(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SAdd{E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{3n}}}}: True{}
    case _: False{}

def union_left_associative(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SUnion{E.SUnion{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{3n}}}}: True{}
    case _: False{}

def coalesce_left_associative(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SCoalesce{E.SCoalesce{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{3n}}}}: True{}
    case _: False{}

def equality_left_associative(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SEq{E.SEq{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{3n}}}}: True{}
    case _: False{}

def parentheses(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SAdd{E.SUnion{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{3n}}}}: True{}
    case _: False{}

def call(result: P.ParseResult) -> Bool:
  match result:
    case P.Parsed{E.SCall{E.Name{text}, Con{E.SLiteral{E.LInt{1n}}, Con{E.SAdd{E.SLiteral{E.LInt{2n}}, E.SLiteral{E.LInt{3n}}}, Nil{}}}}}: String.eq(text, "add")
    case _: False{}

def require(ok: Bool, message: String) -> IO(Unit):
  match ok:
    case True{}: IO.pure(Unit, Unit{})
    case False{}: IO.die(Unit, 1, message)

def main() -> IO(Unit):
  do IO<Unit>:
    require(full_parse(), "full parses must end at EOF")
    require(Bool.and(lexical_failure(Source.parse_source("?")), lexical_document_failure(Source.parse_document_source("?"))), "source entry points must report lexer errors")
    require(deterministic(), "same token stream must have the same result or error")
    require(monotone_remainder(), "subexpression must return the unconsumed token suffix")
    require(expressions_advance(), "successful expressions must consume a prefix, preserving the token suffix")
    require(shape_consumes_suffix([T.TIdentifier{"name"}, T.TComma{}, T.TIdentifier{"age"}, T.TRBrace{}, T.TSemicolon{}, T.TEOF{}]), "simple shape must preserve suffix")
    require(shape_consumes_suffix([T.TIdentifier{"age"}, T.TAssign{}, T.TIntLiteral{1n}, T.TComma{}, T.TIdentifier{"name"}, T.TRBrace{}, T.TEOF{}]), "computed shape must preserve suffix")
    require(shape_consumes_suffix([T.TIdentifier{"profile"}, T.TColon{}, T.TLBrace{}, T.TIdentifier{"name"}, T.TRBrace{}, T.TRBrace{}, T.TSemicolon{}, T.TEOF{}]), "nested shape must preserve suffix")
    require(computed_shape_fields(parse_fields([T.TIdentifier{"age"}, T.TAssign{}, T.TIntLiteral{1n}, T.TPlus{}, T.TIntLiteral{2n}, T.TComma{}, T.TIdentifier{"name"}, T.TRBrace{}, T.TEOF{}])), "binary computed shape and field separator")
    require(call_shape_field(parse_fields([T.TIdentifier{"age"}, T.TAssign{}, T.TIdentifier{"add"}, T.TLParen{}, T.TIntLiteral{1n}, T.TComma{}, T.TIntLiteral{2n}, T.TRParen{}, T.TComma{}, T.TIdentifier{"name"}, T.TRBrace{}, T.TEOF{}])), "call argument and field commas must stay distinct")
    require(insert_with_computed_fields(Source.parse_source("insert Movie { age := 1 + 2, name := 3 }")), "computed fields must parse in complete insert statements")
    require(for_body_consumes_remainder(), "for body must not discard trailing tokens")
    require(precedence(Source.parse_source("1 union 2 ?? 3 = 4 + 5")), "operator precedence")
    require(left_associative(Source.parse_source("1 + 2 + 3")), "left associativity")
    require(union_left_associative(Source.parse_source("1 union 2 union 3")), "union left associativity")
    require(coalesce_left_associative(Source.parse_source("1 ?? 2 ?? 3")), "coalesce left associativity")
    require(equality_left_associative(Source.parse_source("1 = 2 = 3")), "equality left associativity")
    require(parentheses(Source.parse_source("(1 union 2) + 3")), "parentheses precedence")
    require(call(Source.parse_source("add(1, 2 + 3)")), "call arguments and precedence")
