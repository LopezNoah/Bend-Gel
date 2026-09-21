import Base
import ./EdgeQLToken.bend as T
import ./EdgeQLSyntax.bend as E
import ./EdgeQLLexer.bend as L

type ParseError is Data:
  UnexpectedEnd{}
  UnexpectedToken{token: T.Token}
  ExpectedIdentifier{}
  ExpectedShape{}
  UnclosedDelimiter{}
  DocumentUnclosedDelimiter{}
  ParseStepLimit{}
  LexFailure{error: T.LexError}

type ParseResult is Data:
  Parsed{value: E.SurfaceExpr}
  ParseFailed{error: ParseError}

type DocumentResult is Data:
  DocumentParsed{value: E.SurfaceDocument}
  DocumentFailed{error: ParseError}

type DocumentStatementResult is Data:
  DocumentStatementParsed{value: E.SurfaceStatement}
  DocumentStatementFailed{error: ParseError}

type DocumentStatementKind is Data:
  StatementQuery{}
  StatementSchema{}
  StatementUnparsed{}

type Delimiter is Data:
  Brace{}
  Paren{}

type DocumentState is Data:
  DocumentScan{tokens: List<&2, T.Token>, current: List<&2, T.Token>, statements: List<&2, E.SurfaceStatement>, delimiters: List<&2, Delimiter>}
  DocumentFinish{current: List<&2, T.Token>, statements: List<&2, E.SurfaceStatement>}
  DocumentFinishStatement{result: DocumentStatementResult, tokens: List<&2, T.Token>, statements: List<&2, E.SurfaceStatement>}
  DocumentDone{value: E.SurfaceDocument}

type ExprResult is Data:
  ExprParsed{value: E.SurfaceExpr, rest: List<&2, T.Token>}
  ExprFailed{error: ParseError}

type Operator is Data:
  OUnion{}
  OCoalesce{}
  OEquals{}
  OAdd{}
  OParen{}
  OCall{name: E.Name, args: List<&2, E.SurfaceExpr>}

type EndKind is Data:
  KeepToken{}
  CloseParen{}
  Comma{}

type ExprState is Data:
  Scan{tokens: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>}
  ReduceOperator{incoming: Operator, tokens: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>}
  End{end_kind: EndKind, rest: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>}
  Finished{value: E.SurfaceExpr, rest: List<&2, T.Token>}
  Failed{error: ParseError}

type ShapeContinuation is Data:
  ShapeDone{}
  ShapeNestedContinuation{name: E.Name, fields: List<&2, E.SurfaceExpr>, continuation: ShapeContinuation}

type ShapeState is Data:
  ShapeScan{tokens: List<&2, T.Token>, fields: List<&2, E.SurfaceExpr>, continuation: ShapeContinuation}
  ShapeAfter{field: E.SurfaceExpr, tokens: List<&2, T.Token>, fields: List<&2, E.SurfaceExpr>, continuation: ShapeContinuation}
  ShapeError{error: ParseError}
  ShapeFinished{fields: List<&2, E.SurfaceExpr>, rest: List<&2, T.Token>}

type ShapeResult is Data:
  ShapeParsed{fields: List<&2, E.SurfaceExpr>, rest: List<&2, T.Token>}
  ShapeFailed{error: ParseError}

def operator_precedence(operator: Operator) -> Nat:
  match operator:
    case OUnion{}: 1n
    case OCoalesce{}: 2n
    case OEquals{}: 3n
    case OAdd{}: 4n
    case OParen{}: 0n
    case OCall{name, args}: 0n

def apply_operator(operator: Operator, left: E.SurfaceExpr, right: E.SurfaceExpr) -> E.SurfaceExpr:
  match operator:
    case OUnion{}: E.SUnion{left, right}
    case OCoalesce{}: E.SCoalesce{left, right}
    case OEquals{}: E.SEq{left, right}
    case OAdd{}: E.SAdd{left, right}
    case OParen{}: left
    case OCall{name, args}: E.SCall{name, Con{left, args}}

def binary_operator(token: T.Token) -> Maybe<&2, Operator>:
  match token:
    case T.TUnion{}: Some{OUnion{}}
    case T.TCoalesce{}: Some{OCoalesce{}}
    case T.TEquals{}: Some{OEquals{}}
    case T.TPlus{}: Some{OAdd{}}
    case _: None{}

def parse_literal_identifier(text: String) -> E.Literal:
  match text:
    case "true": E.LBool{True{}}
    case "false": E.LBool{False{}}
    case _: E.LString{text}

def push_value(value: E.SurfaceExpr, +values: List<&2, E.SurfaceExpr>) -> List<&2, E.SurfaceExpr>:
  Con{value, values}

def reduce_binary(operator: Operator, +values: List<&2, E.SurfaceExpr>) -> Maybe<&2, List<&2, E.SurfaceExpr>>:
  match values:
    case Con{right, Con{left, rest}}: Some{Con{apply_operator(operator, left, right), rest}}
    case _: None{}

def parse_binary_token(result: Maybe<&2, Operator>, token: T.Token, rest: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match result:
    case None{}: End{KeepToken{}, Con{token, rest}, values, operators}
    case Some{operator}: ReduceOperator{operator, rest, values, operators}

def reduce_operator_result(result: Maybe<&2, List<&2, E.SurfaceExpr>>, incoming: Operator, tokens: List<&2, T.Token>, operators: List<&2, Operator>) -> ExprState:
  match result:
    case None{}: Failed{UnclosedDelimiter{}}
    case Some{values}: ReduceOperator{incoming, tokens, values, operators}

def reduce_operator_compare(can_reduce: Bool, top: Operator, rest: List<&2, Operator>, incoming: Operator, tokens: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match can_reduce:
    case True{}:
      reduce_operator_result(reduce_binary(top, values), incoming, tokens, rest)
    case False{}:
      Scan{tokens, values, Con{incoming, operators}}

def operator_levels_result(+top: Operator, rest: List<&2, Operator>, +incoming: Operator, tokens: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  reduce_operator_compare(Nat.is_ge(operator_precedence(top), operator_precedence(incoming)), top, rest, incoming, tokens, values, operators)

def end_reduce_result(result: Maybe<&2, List<&2, E.SurfaceExpr>>, kind: EndKind, rest: List<&2, T.Token>, operators: List<&2, Operator>) -> ExprState:
  match result:
    case None{}: Failed{UnexpectedToken{T.TEOF{}}}
    case Some{values}: End{kind, rest, values, operators}

def end_call_comma(name: E.Name, args: List<&2, E.SurfaceExpr>, rest: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match values:
    case Con{argument, value_tail}: Scan{rest, value_tail, Con{OCall{name, Con{argument, args}}, operators}}
    case _: Failed{UnexpectedToken{T.TComma{}}}

def end_call_close(name: E.Name, args: List<&2, E.SurfaceExpr>, rest: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match values:
    case Nil{}: Scan{rest, Con{E.SCall{name, List.reverse(&2, E.SurfaceExpr, args)}, Nil{}}, operators}
    case Con{argument, value_tail}: Scan{rest, Con{E.SCall{name, List.reverse(&2, E.SurfaceExpr, Con{argument, args})}, value_tail}, operators}

def finish_values(+values: List<&2, E.SurfaceExpr>, rest: List<&2, T.Token>) -> ExprState:
  match values:
    case Con{value, Nil{}}: Finished{value, rest}
    case _: Failed{UnexpectedEnd{}}

def end_close(rest: List<&2, T.Token>, +values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match operators:
    case Con{top, operator_tail}:
      match top:
        case OParen{}: Scan{rest, values, operator_tail}
        case OCall{name, args}: end_call_close(name, args, rest, values, operator_tail)
        case _: end_reduce_result(reduce_binary(top, values), CloseParen{}, rest, operator_tail)
    case Nil{}:
      finish_values(values, rest)

def end_comma(rest: List<&2, T.Token>, +values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match operators:
    case Con{top, operator_tail}:
      match top:
        case OCall{name, args}: end_call_comma(name, args, rest, values, operator_tail)
        case _: Failed{UnexpectedToken{T.TComma{}}}
    case Nil{}: Failed{UnexpectedToken{T.TComma{}}}

def end_keep(rest: List<&2, T.Token>, +values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match operators:
    case Con{top, operator_tail}:
      match top:
        case OParen{}: Failed{UnclosedDelimiter{}}
        case OCall{name, args}: Failed{UnclosedDelimiter{}}
        case _: end_reduce_result(reduce_binary(top, values), KeepToken{}, rest, operator_tail)
    case Nil{}:
      finish_values(values, rest)

def end_action(end_kind: EndKind, rest: List<&2, T.Token>, values: List<&2, E.SurfaceExpr>, operators: List<&2, Operator>) -> ExprState:
  match end_kind:
    case CloseParen{}: end_close(rest, values, operators)
    case Comma{}: end_comma(rest, values, operators)
    case KeepToken{}: end_keep(rest, values, operators)

def shape_expression_state(result: ExprResult, name: E.Name, fields: List<&2, E.SurfaceExpr>, continuation: ShapeContinuation) -> ShapeState:
  match result:
    case ExprFailed{error}: ShapeError{error}
    case ExprParsed{value, rest}: ShapeAfter{E.SShapeComputed{name, value}, rest, fields, continuation}

def shape_close_state(continuation: ShapeContinuation, fields: List<&2, E.SurfaceExpr>, rest: List<&2, T.Token>) -> ShapeState:
  match continuation:
    case ShapeDone{}: ShapeFinished{List.reverse(&2, E.SurfaceExpr, fields), rest}
    case ShapeNestedContinuation{name, outer_fields, outer_continuation}:
      ShapeAfter{E.SShapeNested{name, List.reverse(&2, E.SurfaceExpr, fields)}, rest, outer_fields, outer_continuation}

def parse_expr_go(fuel: Nat, state: ExprState) -> ExprResult:
  match fuel:
    case 0n: ExprFailed{ParseStepLimit{}}
    case 1n+ +remaining:
      match state:
        case Scan{tokens, values, operators}:
          match tokens:
            case Nil{}:
            parse_expr_go(remaining, End{KeepToken{}, Nil{}, values, operators})
            case Con{+token, +rest}:
              match token:
                case T.TEOF{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TIdentifier{text}:
                  match values:
                    case Nil{}:
                      parse_expr_go(remaining, Scan{rest, push_value(E.SName{E.Name{text}}, values), operators})
                    case _:
                      parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TStringLiteral{text}:
                  parse_expr_go(remaining, Scan{rest, push_value(E.SLiteral{E.LString{text}}, values), operators})
                case T.TIntLiteral{value}:
                  parse_expr_go(remaining, Scan{rest, push_value(E.SLiteral{E.LInt{value}}, values), operators})
                case T.TDollar{}:
                  match rest:
                    case Con{T.TIdentifier{text}, tail}:
                      parse_expr_go(remaining, Scan{tail, push_value(E.SVariable{E.Name{text}}, values), operators})
                    case _: ExprFailed{ExpectedIdentifier{}}
                case T.TDot{}:
                  match rest:
                    case Con{T.TIdentifier{text}, tail}:
                      match values:
                        case Nil{}:
                          parse_expr_go(remaining, Scan{tail, push_value(E.SPartialPath{E.Name{text}}, values), operators})
                        case Con{source, value_tail}:
                          parse_expr_go(remaining, Scan{tail, push_value(E.SPath{source, E.Name{text}}, value_tail), operators})
                    case _: ExprFailed{ExpectedIdentifier{}}
                case T.TLParen{}:
                  match values:
                    case Con{E.SName{name}, value_tail}:
                      parse_expr_go(remaining, Scan{rest, value_tail, Con{OCall{name, Nil{}}, operators}})
                    case _:
                      parse_expr_go(remaining, Scan{rest, values, Con{OParen{}, operators}})
                case T.TRParen{}:
                  parse_expr_go(remaining, End{CloseParen{}, rest, values, operators})
                case T.TComma{}:
                  parse_expr_go(remaining, End{Comma{}, rest, values, operators})
                case T.TFilter{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TOrder{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TBy{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TAsc{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TDesc{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TSelect{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TSet{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TIn{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TLBrace{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TRBrace{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case T.TSemicolon{}:
                  parse_expr_go(remaining, End{KeepToken{}, tokens, values, operators})
                case _: 
                  parse_expr_go(remaining, parse_binary_token(binary_operator(token), token, rest, values, operators))
        case ReduceOperator{+incoming, tokens, values, operators}:
          match operators:
            case Nil{}:
              parse_expr_go(remaining, Scan{tokens, values, Con{incoming, Nil{}}})
            case Con{+top, +rest}:
              match top:
                case OParen{}:
                  parse_expr_go(remaining, Scan{tokens, values, Con{incoming, operators}})
                case OCall{name, args}:
                  parse_expr_go(remaining, Scan{tokens, values, Con{incoming, operators}})
                case _:
                  top_level = operator_precedence(top)
                  incoming_level = operator_precedence(incoming)
                  parse_expr_go(remaining, operator_levels_result(top, rest, incoming, tokens, values, operators))
        case End{end_kind, rest, values, operators}:
          parse_expr_go(remaining, end_action(end_kind, rest, values, operators))
        case Finished{value, rest}: ExprParsed{value, rest}
        case Failed{error}: ExprFailed{error}

def parse_shape_go(fuel: Nat, state: ShapeState) -> ShapeResult:
  match fuel:
    case 0n: ShapeFailed{ParseStepLimit{}}
    case 1n+ +remaining:
      match state:
        case ShapeScan{tokens, fields, continuation}:
          match tokens:
            case Nil{}: ShapeFailed{UnexpectedEnd{}}
            case Con{token, +tail_tokens}:
              match token tail_tokens:
                case T.TRBrace{} _:
                  parse_shape_go(remaining, shape_close_state(continuation, fields, tail_tokens))
                case T.TIdentifier{text} Con{T.TAssign{}, tail}:
                  name = {E.Name{text} : E.Name}
                  expression_result = parse_expr_go(100000n, Scan{tail, Nil{}, Nil{}})
                  parse_shape_go(remaining, shape_expression_state(expression_result, name, fields, continuation))
                case T.TIdentifier{text} Con{T.TColon{}, Con{T.TLBrace{}, tail}}:
                  name = {E.Name{text} : E.Name}
                  parse_shape_go(remaining, ShapeScan{tail, Nil{}, ShapeNestedContinuation{name, fields, continuation}})
                case T.TIdentifier{text} _:
                  parse_shape_go(remaining, ShapeAfter{E.SShapeField{E.Name{text}}, tail_tokens, fields, continuation})
                case _ _: ShapeFailed{UnexpectedToken{token}}
        case ShapeAfter{field, tokens, fields, continuation}:
          match tokens:
            case Con{T.TComma{}, rest}:
              parse_shape_go(remaining, ShapeScan{rest, Con{field, fields}, continuation})
            case Con{T.TRBrace{}, rest}:
              parse_shape_go(remaining, shape_close_state(continuation, Con{field, fields}, rest))
            case _: ShapeFailed{ExpectedShape{}}
        case ShapeError{error}: ShapeFailed{error}
        case ShapeFinished{fields, rest}: ShapeParsed{fields, rest}

def no_filter() -> E.SurfaceExpr:
  E.SNoFilter{}

def no_order() -> E.SurfaceExpr:
  E.SNoOrder{}

def finish_query(value: E.SurfaceExpr, tokens: List<&2, T.Token>) -> ParseResult:
  match tokens:
    case Con{T.TEOF{}, rest}: Parsed{value}
    case Con{T.TSemicolon{}, Con{T.TEOF{}, rest}}: Parsed{value}
    case Con{token, rest}: ParseFailed{UnexpectedToken{token}}
    case Nil{}: Parsed{value}

type SelectState is Data:
  SelectScan{result: E.SurfaceExpr, shape: List<&2, E.SurfaceExpr>, filter: E.SurfaceExpr, order: E.SurfaceExpr, tokens: List<&2, T.Token>}
  SelectFailure{error: ParseError}

def select_filter_state(result: ExprResult, query: E.SurfaceExpr, shape: List<&2, E.SurfaceExpr>, order: E.SurfaceExpr) -> SelectState:
  match result:
    case ExprFailed{error}: SelectFailure{error}
    case ExprParsed{value, rest}: SelectScan{query, shape, E.SFilter{value}, order, rest}

def select_order_tail(rest: List<&2, T.Token>, key: E.SurfaceExpr, query: E.SurfaceExpr, shape: List<&2, E.SurfaceExpr>, filter: E.SurfaceExpr) -> SelectState:
  match rest:
    case Con{T.TDesc{}, tail}: SelectScan{query, shape, filter, E.SOrder{key, E.Desc{}}, tail}
    case Con{T.TAsc{}, tail}: SelectScan{query, shape, filter, E.SOrder{key, E.Asc{}}, tail}
    case _: SelectScan{query, shape, filter, E.SOrder{key, E.Asc{}}, rest}

def select_order_state(result: ExprResult, query: E.SurfaceExpr, shape: List<&2, E.SurfaceExpr>, filter: E.SurfaceExpr) -> SelectState:
  match result:
    case ExprFailed{error}: SelectFailure{error}
    case ExprParsed{key, rest}: select_order_tail(rest, key, query, shape, filter)

def parse_select_tail(fuel: Nat, state: SelectState) -> ParseResult:
  match fuel:
    case 0n: ParseFailed{ParseStepLimit{}}
    case 1n+remaining:
      match state:
        case SelectFailure{error}: ParseFailed{error}
        case SelectScan{result, shape, filter, order, tokens}:
          match tokens:
            case Con{T.TFilter{}, rest}:
              expression_result = parse_expr_go(100000n, Scan{rest, Nil{}, Nil{}})
              parse_select_tail(remaining, select_filter_state(expression_result, result, shape, order))
            case Con{T.TOrder{}, Con{T.TBy{}, rest}}:
              expression_result = parse_expr_go(100000n, Scan{rest, Nil{}, Nil{}})
              parse_select_tail(remaining, select_order_state(expression_result, result, shape, filter))
            case _: finish_query(E.SSelect{result, shape, filter, order}, tokens)

type StatementState is Data:
  StatementTokens{tokens: List<&2, T.Token>}
  SelectExpression{result: ExprResult}
  SelectShapeTokens{query: E.SurfaceExpr, tokens: List<&2, T.Token>}
  SelectShapeResult{query: E.SurfaceExpr, result: ShapeResult}
  RunSelect{state: SelectState}
  WithExpression{name: E.Name, result: ExprResult}
  WithBodyStart{name: E.Name, bound: E.SurfaceExpr, tokens: List<&2, T.Token>}
  ForExpression{name: E.Name, result: ExprResult}
  ForBodyTokens{name: E.Name, source: E.SurfaceExpr, tokens: List<&2, T.Token>}
  ForBodyExpression{name: E.Name, source: E.SurfaceExpr, result: ExprResult}
  InsertShapeTokens{name: E.Name, tokens: List<&2, T.Token>}
  InsertShapeResult{name: E.Name, result: ShapeResult}
  UpdateSourceExpression{result: ExprResult}
  UpdateFilterTokens{source: E.SurfaceExpr, tokens: List<&2, T.Token>}
  UpdateFilterResult{source: E.SurfaceExpr, result: ExprResult}
  UpdateShapeTokens{source: E.SurfaceExpr, filter: E.SurfaceExpr, tokens: List<&2, T.Token>}
  UpdateShapeResult{source: E.SurfaceExpr, filter: E.SurfaceExpr, result: ShapeResult}
  FinalExpression{result: ExprResult}
  StatementFailure{error: ParseError}

def select_expression_state(result: ExprResult) -> StatementState:
  match result:
    case ExprFailed{error}: StatementFailure{error}
    case ExprParsed{value, rest}:
      match rest:
        case Con{T.TLBrace{}, shape_tokens}: SelectShapeTokens{value, shape_tokens}
        case _: RunSelect{SelectScan{value, Nil{}, E.SNoFilter{}, E.SNoOrder{}, rest}}

def select_shape_state(result: ShapeResult, query: E.SurfaceExpr) -> StatementState:
  match result:
    case ShapeFailed{error}: StatementFailure{error}
    case ShapeParsed{fields, rest}: RunSelect{SelectScan{query, fields, E.SNoFilter{}, E.SNoOrder{}, rest}}

def select_shape_result(result: ShapeResult, query: E.SurfaceExpr) -> ParseResult:
  match result:
    case ShapeFailed{error}: ParseFailed{error}
    case ShapeParsed{fields, rest}: parse_select_tail(100000n, SelectScan{query, fields, E.SNoFilter{}, E.SNoOrder{}, rest})

def with_expression_state(result: ExprResult, name: E.Name) -> StatementState:
  match result:
    case ExprFailed{error}: StatementFailure{error}
    case ExprParsed{value, rest}:
      match rest:
        case Con{T.TSelect{}, body_tokens}: WithBodyStart{name, value, body_tokens}
        case Con{token, tail}: StatementFailure{UnexpectedToken{token}}
        case Nil{}: StatementFailure{UnexpectedEnd{}}

def with_body_result(result: ParseResult, name: E.Name, bound: E.SurfaceExpr) -> ParseResult:
  match result:
    case ParseFailed{error}: ParseFailed{error}
    case Parsed{body}: Parsed{E.SWith{name, bound, body}}

def for_expression_state(result: ExprResult, name: E.Name) -> StatementState:
  match result:
    case ExprFailed{error}: StatementFailure{error}
    case ExprParsed{source, rest}:
      match rest:
        case Con{T.TUnion{}, body_tokens}: ForBodyTokens{name, source, body_tokens}
        case Con{token, tail}: StatementFailure{UnexpectedToken{token}}
        case Nil{}: StatementFailure{UnexpectedEnd{}}

def for_body_result(result: ExprResult, name: E.Name, source: E.SurfaceExpr) -> ParseResult:
  match result:
    case ExprFailed{error}: ParseFailed{error}
    case ExprParsed{body, rest}: Parsed{E.SFor{name, source, body}}

def insert_shape_state(result: ShapeResult, name: E.Name) -> StatementState:
  match result:
    case ShapeFailed{error}: StatementFailure{error}
    case ShapeParsed{fields, rest}: InsertShapeResult{name, ShapeParsed{fields, rest}}

def insert_shape_result(result: ShapeResult, name: E.Name) -> ParseResult:
  match result:
    case ShapeFailed{error}: ParseFailed{error}
    case ShapeParsed{fields, rest}: finish_query(E.SInsert{name, fields}, rest)

def update_source_state(result: ExprResult) -> StatementState:
  match result:
    case ExprFailed{error}: StatementFailure{error}
    case ExprParsed{source, rest}:
      match rest:
        case Con{T.TFilter{}, filter_tokens}: UpdateFilterTokens{source, filter_tokens}
        case Con{T.TSet{}, Con{T.TLBrace{}, shape_tokens}}: UpdateShapeTokens{source, E.SNoFilter{}, shape_tokens}
        case _: StatementFailure{ExpectedShape{}}

def update_filter_state(result: ExprResult, source: E.SurfaceExpr) -> StatementState:
  match result:
    case ExprFailed{error}: StatementFailure{error}
    case ExprParsed{filter, rest}:
      match rest:
        case Con{T.TSet{}, Con{T.TLBrace{}, shape_tokens}}: UpdateShapeTokens{source, E.SFilter{filter}, shape_tokens}
        case _: StatementFailure{ExpectedShape{}}

def update_shape_state(result: ShapeResult, source: E.SurfaceExpr, filter: E.SurfaceExpr) -> StatementState:
  match result:
    case ShapeFailed{error}: StatementFailure{error}
    case ShapeParsed{fields, rest}: UpdateShapeResult{source, filter, ShapeParsed{fields, rest}}

def update_shape_result(result: ShapeResult, source: E.SurfaceExpr, filter: E.SurfaceExpr) -> ParseResult:
  match result:
    case ShapeFailed{error}: ParseFailed{error}
    case ShapeParsed{fields, rest}: finish_query(E.SUpdate{source, filter, fields}, rest)

def final_expression_state(result: ExprResult) -> StatementState:
  match result:
    case ExprFailed{error}: StatementFailure{error}
    case ExprParsed{value, rest}: FinalExpression{ExprParsed{value, rest}}

def final_expression_result(result: ExprResult) -> ParseResult:
  match result:
    case ExprFailed{error}: ParseFailed{error}
    case ExprParsed{value, rest}: finish_query(value, rest)

def parse_statement(fuel: Nat, state: StatementState) -> ParseResult:
  match fuel:
    case 0n: ParseFailed{ParseStepLimit{}}
    case 1n+remaining:
      match state:
        case StatementFailure{error}: ParseFailed{error}
        case StatementTokens{tokens}:
          match tokens:
            case Con{T.TSelect{}, rest}:
              expression_result = parse_expr_go(100000n, Scan{rest, Nil{}, Nil{}})
              parse_statement(remaining, select_expression_state(expression_result))
            case Con{T.TWith{}, Con{T.TIdentifier{text}, Con{T.TAssign{}, rest}}}:
              expression_result = parse_expr_go(100000n, Scan{rest, Nil{}, Nil{}})
              parse_statement(remaining, with_expression_state(expression_result, E.Name{text}))
            case Con{T.TFor{}, Con{T.TIdentifier{text}, Con{T.TIn{}, rest}}}:
              expression_result = parse_expr_go(100000n, Scan{rest, Nil{}, Nil{}})
              parse_statement(remaining, for_expression_state(expression_result, E.Name{text}))
            case Con{T.TInsert{}, Con{T.TIdentifier{text}, Con{T.TLBrace{}, rest}}}:
              shape_result = parse_shape_go(remaining, ShapeScan{rest, Nil{}, ShapeDone{}})
              insert_shape_result(shape_result, E.Name{text})
            case Con{T.TUpdate{}, rest}:
              expression_result = parse_expr_go(100000n, Scan{rest, Nil{}, Nil{}})
              parse_statement(remaining, update_source_state(expression_result))
            case _:
              expression_result = parse_expr_go(100000n, Scan{tokens, Nil{}, Nil{}})
              parse_statement(remaining, final_expression_state(expression_result))
        case SelectExpression{result}:
          parse_statement(remaining, select_expression_state(result))
        case SelectShapeTokens{query, tokens}:
          select_shape_result(parse_shape_go(remaining, ShapeScan{tokens, Nil{}, ShapeDone{}}), query)
        case SelectShapeResult{query, result}:
          select_shape_result(result, query)
        case RunSelect{state}: parse_select_tail(remaining, state)
        case WithExpression{name, result}: parse_statement(remaining, with_expression_state(result, name))
        case WithBodyStart{name, bound, tokens}:
          with_body_result(parse_statement(remaining, StatementTokens{Con{T.TSelect{}, tokens}}), name, bound)
        case ForExpression{name, result}: parse_statement(remaining, for_expression_state(result, name))
        case ForBodyTokens{name, source, tokens}:
          for_body_result(parse_expr_go(100000n, Scan{tokens, Nil{}, Nil{}}), name, source)
        case ForBodyExpression{name, source, result}: for_body_result(result, name, source)
        case InsertShapeTokens{name, tokens}:
          insert_shape_result(parse_shape_go(remaining, ShapeScan{tokens, Nil{}, ShapeDone{}}), name)
        case InsertShapeResult{name, result}: insert_shape_result(result, name)
        case UpdateSourceExpression{result}: parse_statement(remaining, update_source_state(result))
        case UpdateFilterTokens{source, tokens}:
          parse_statement(remaining, update_filter_state(parse_expr_go(100000n, Scan{tokens, Nil{}, Nil{}}), source))
        case UpdateFilterResult{source, result}: parse_statement(remaining, update_filter_state(result, source))
        case UpdateShapeTokens{source, filter, tokens}:
          update_shape_result(parse_shape_go(remaining, ShapeScan{tokens, Nil{}, ShapeDone{}}), source, filter)
        case UpdateShapeResult{source, filter, result}: update_shape_result(result, source, filter)
        case FinalExpression{result}:
          final_expression_result(result)

def parse(tokens: List<&2, T.Token>) -> ParseResult:
  parse_statement(100000n, StatementTokens{tokens})

def lexical_parse_result(result: T.LexResult) -> ParseResult:
  match result:
    case T.LexFailed{error}: ParseFailed{LexFailure{error}}
    case T.Lexed{tokens}: parse(tokens)

def parse_source(source: String) -> ParseResult:
  lexical_parse_result(L.lex(source))

def is_schema_word(text: String) -> Bool:
  match text:
    case "module": True{}
    case "type": True{}
    case "abstract": True{}
    case "scalar": True{}
    case "function": True{}
    case "alias": True{}
    case "constraint": True{}
    case "annotation": True{}
    case "create": True{}
    case "alter": True{}
    case "drop": True{}
    case "configure": True{}
    case "grant": True{}
    case "revoke": True{}
    case "extension": True{}
    case "migration": True{}
    case _: False{}

def statement_kind_schema(is_schema: Bool) -> DocumentStatementKind:
  match is_schema:
    case True{}: StatementSchema{}
    case False{}: StatementUnparsed{}

def statement_kind(token: T.Token) -> DocumentStatementKind:
  match token:
    case T.TSelect{}: StatementQuery{}
    case T.TWith{}: StatementQuery{}
    case T.TFor{}: StatementQuery{}
    case T.TInsert{}: StatementQuery{}
    case T.TUpdate{}: StatementQuery{}
    case T.TIdentifier{text}: statement_kind_schema(is_schema_word(text))
    case _: StatementUnparsed{}

def query_document_statement(result: ParseResult) -> DocumentStatementResult:
  match result:
    case Parsed{value}: DocumentStatementParsed{E.SQuery{value}}
    case ParseFailed{error}: DocumentStatementFailed{error}

def document_statement_kind(kind: DocumentStatementKind, tokens: List<&2, T.Token>) -> DocumentStatementResult:
  match kind:
    case StatementQuery{}: query_document_statement(parse(tokens))
    case StatementSchema{}: DocumentStatementParsed{E.SSchema{tokens}}
    case StatementUnparsed{}: DocumentStatementParsed{E.SUnparsed{tokens}}

def parse_document_statement(tokens: List<&2, T.Token>) -> DocumentStatementResult:
  match tokens:
    case Nil{}: DocumentStatementFailed{UnexpectedEnd{}}
    case Con{+first, rest}: document_statement_kind(statement_kind(first), tokens)

def document_starts_query_token(token: T.Token) -> Bool:
  match token:
    case T.TIdentifier{text}: Bool.not(is_schema_word(text))
    case _: True{}

def document_starts_query(tokens: List<&2, T.Token>) -> Bool:
  match tokens:
    case Nil{}: False{}
    case Con{head, Nil{}}: document_starts_query_token(head)
    case Con{head, tail}: document_starts_query(tail)

def document_close_kind(is_query: Bool, token: T.Token, +tokens: List<&2, T.Token>, +current: List<&2, T.Token>, statements: List<&2, E.SurfaceStatement>, delimiters: List<&2, Delimiter>) -> DocumentState:
  match is_query:
    case True{}: DocumentScan{tokens, Con{token, current}, statements, delimiters}
    case False{}:
      result = parse_document_statement(List.reverse(&2, T.Token, Con{token, current}))
      DocumentFinishStatement{result, tokens, statements}

def document_close_boundary(is_query: Bool, token: T.Token, +tokens: List<&2, T.Token>, +current: List<&2, T.Token>, statements: List<&2, E.SurfaceStatement>, delimiters: List<&2, Delimiter>) -> DocumentState:
  match tokens:
    case Con{T.TSemicolon{}, rest}: DocumentScan{tokens, Con{token, current}, statements, delimiters}
    case _: document_close_kind(is_query, token, tokens, current, statements, delimiters)

def document_go(fuel: Nat, state: DocumentState) -> DocumentResult:
  match fuel:
    case 0n: DocumentFailed{ParseStepLimit{}}
    case 1n+ +remaining:
      match state:
        case DocumentScan{tokens, +current, statements, delimiters}:
          match tokens:
            case Nil{}: document_go(remaining, DocumentFinish{current, statements})
            case Con{token, +tail}:
              match token:
                case T.TEOF{}:
                  match delimiters:
                    case Nil{}: document_go(remaining, DocumentFinish{current, statements})
                    case _: DocumentFailed{DocumentUnclosedDelimiter{}}
                case T.TSemicolon{}:
                  match delimiters:
                    case Nil{}:
                      result = parse_document_statement(List.reverse(&2, T.Token, current))
                      document_go(remaining, DocumentFinishStatement{result, tail, statements})
                    case _:
                      document_go(remaining, DocumentScan{tail, Con{token, current}, statements, delimiters})
                case T.TLBrace{}:
                  document_go(remaining, DocumentScan{tail, Con{token, current}, statements, Con{Brace{}, delimiters}})
                case T.TLParen{}:
                  document_go(remaining, DocumentScan{tail, Con{token, current}, statements, Con{Paren{}, delimiters}})
                case T.TRBrace{}:
                  match delimiters:
                    case Nil{}: DocumentFailed{DocumentUnclosedDelimiter{}}
                    case Con{Brace{}, Nil{}}:
                      document_go(remaining, document_close_boundary(document_starts_query(current), token, tail, current, statements, Nil{}))
                    case Con{Brace{}, rest}:
                      document_go(remaining, DocumentScan{tail, Con{token, current}, statements, rest})
                    case Con{Paren{}, rest}: DocumentFailed{DocumentUnclosedDelimiter{}}
                case T.TRParen{}:
                  match delimiters:
                    case Nil{}: DocumentFailed{DocumentUnclosedDelimiter{}}
                    case Con{Paren{}, rest}: document_go(remaining, DocumentScan{tail, Con{token, current}, statements, rest})
                    case Con{Brace{}, rest}: DocumentFailed{DocumentUnclosedDelimiter{}}
                case _:
                  document_go(remaining, DocumentScan{tail, Con{token, current}, statements, delimiters})
        case DocumentFinish{current, statements}:
          match current:
            case Nil{}: document_go(remaining, DocumentDone{E.Document{List.reverse(&2, E.SurfaceStatement, statements)}})
            case _:
              result = parse_document_statement(List.reverse(&2, T.Token, current))
              document_go(remaining, DocumentFinishStatement{result, Nil{}, statements})
        case DocumentFinishStatement{result, tokens, statements}:
          match result:
            case DocumentStatementFailed{error}: DocumentFailed{error}
            case DocumentStatementParsed{value}:
              document_go(remaining, DocumentScan{tokens, Nil{}, Con{value, statements}, Nil{}})
        case DocumentDone{value}: DocumentParsed{value}

def parse_document(tokens: List<&2, T.Token>) -> DocumentResult:
  document_go(100000n, DocumentScan{tokens, Nil{}, Nil{}, Nil{}})

def lexical_document_result(result: T.LexResult) -> DocumentResult:
  match result:
    case T.LexFailed{error}: DocumentFailed{LexFailure{error}}
    case T.Lexed{tokens}: parse_document(tokens)

def parse_document_source(source: String) -> DocumentResult:
  lexical_document_result(L.lex(source))
