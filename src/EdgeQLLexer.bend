import Base
import ./EdgeQLToken.bend as T

type CharKind is Data:
  KSpace{}
  KIdentifierStart{}
  KDigit{}
  KQuote{}
  KDollar{}
  KDot{}
  KComma{}
  KLBrace{}
  KRBrace{}
  KLParen{}
  KRParen{}
  KColon{}
  KEquals{}
  KPlus{}
  KSemicolon{}
  KQuestion{}
  KHash{}
  KOther{}

type LexState is Data:
  Normal{remaining: String, tokens: List<&2, T.Token>}
  Word{remaining: String, chars: List<&2, Char>, tokens: List<&2, T.Token>}
  Number{remaining: String, chars: List<&2, Char>, tokens: List<&2, T.Token>}
  Quoted{quote: Char, remaining: String, chars: List<&2, Char>, tokens: List<&2, T.Token>}
  Comment{remaining: String, tokens: List<&2, T.Token>}
  Invalid{character: Char}
  WordDone{character: Char, rest: String, chars: List<&2, Char>, tokens: List<&2, T.Token>}
  NumberDone{character: Char, rest: String, chars: List<&2, Char>, tokens: List<&2, T.Token>}
  Dispatch{character: Char, rest: String, tokens: List<&2, T.Token>}
  ClassifiedNormal{character: Char, rest: String, tokens: List<&2, T.Token>, kind: CharKind}
  ClassifiedWord{character: Char, rest: String, chars: List<&2, Char>, tokens: List<&2, T.Token>, kind: CharKind}
  ClassifiedNumber{character: Char, rest: String, chars: List<&2, Char>, tokens: List<&2, T.Token>, kind: CharKind}
  ClassifiedQuoted{character: Char, rest: String, chars: List<&2, Char>, tokens: List<&2, T.Token>, kind: CharKind, quote: Char}
  ClassifiedDispatch{character: Char, rest: String, tokens: List<&2, T.Token>, kind: CharKind}
  CommentClassified{character: Char, rest: String, tokens: List<&2, T.Token>, at_line_end: Bool}
  ColonDispatch{character: Char, rest: String, tokens: List<&2, T.Token>}
  ColonClassified{character: Char, rest: String, tokens: List<&2, T.Token>, next: Char, tail: String, kind: CharKind}
  QuestionDispatch{character: Char, rest: String, tokens: List<&2, T.Token>}
  QuestionClassified{character: Char, rest: String, tokens: List<&2, T.Token>, next: Char, tail: String, kind: CharKind}

def char_is(c: Char, code: U32) -> Bool:
  Char.is_eq(c, Char.from_u32(code))

def char_kind_question(+code: U32, question: Bool) -> CharKind:
  match question:
    case True{}: KQuestion{}
    case False{}: KOther{}

def char_kind_hash(+code: U32, hash: Bool) -> CharKind:
  match hash:
    case True{}: KHash{}
    case False{}: char_kind_question(code, U32.is_eq(code, 63))

def char_kind_semicolon(+code: U32, semicolon: Bool) -> CharKind:
  match semicolon:
    case True{}: KSemicolon{}
    case False{}: char_kind_hash(code, U32.is_eq(code, 35))

def char_kind_plus(+code: U32, plus: Bool) -> CharKind:
  match plus:
    case True{}: KPlus{}
    case False{}: char_kind_semicolon(code, U32.is_eq(code, 59))

def char_kind_equals(+code: U32, equals: Bool) -> CharKind:
  match equals:
    case True{}: KEquals{}
    case False{}: char_kind_plus(code, U32.is_eq(code, 43))

def char_kind_colon(+code: U32, colon: Bool) -> CharKind:
  match colon:
    case True{}: KColon{}
    case False{}: char_kind_equals(code, U32.is_eq(code, 61))

def char_kind_rparen(+code: U32, paren: Bool) -> CharKind:
  match paren:
    case True{}: KRParen{}
    case False{}: char_kind_colon(code, U32.is_eq(code, 58))

def char_kind_lparen(+code: U32, paren: Bool) -> CharKind:
  match paren:
    case True{}: KLParen{}
    case False{}: char_kind_rparen(code, U32.is_eq(code, 41))

def char_kind_rbrace(+code: U32, brace: Bool) -> CharKind:
  match brace:
    case True{}: KRBrace{}
    case False{}: char_kind_lparen(code, U32.is_eq(code, 40))

def char_kind_lbrace(+code: U32, brace: Bool) -> CharKind:
  match brace:
    case True{}: KLBrace{}
    case False{}: char_kind_rbrace(code, U32.is_eq(code, 125))

def char_kind_comma(+code: U32, comma: Bool) -> CharKind:
  match comma:
    case True{}: KComma{}
    case False{}: char_kind_lbrace(code, U32.is_eq(code, 123))

def char_kind_dot(+code: U32, dot: Bool) -> CharKind:
  match dot:
    case True{}: KDot{}
    case False{}: char_kind_comma(code, U32.is_eq(code, 44))

def char_kind_dollar(+code: U32, dollar: Bool) -> CharKind:
  match dollar:
    case True{}: KDollar{}
    case False{}: char_kind_dot(code, U32.is_eq(code, 46))

def char_kind_quote(+code: U32, quote: Bool) -> CharKind:
  match quote:
    case True{}: KQuote{}
    case False{}: char_kind_dollar(code, U32.is_eq(code, 36))

def char_kind_digit(+code: U32, digit: Bool) -> CharKind:
  match digit:
    case True{}: KDigit{}
    case False{}: char_kind_quote(code, Bool.or(U32.is_eq(code, 34), U32.is_eq(code, 39)))

def char_kind_start(+code: U32, start: Bool) -> CharKind:
  match start:
    case True{}: KIdentifierStart{}
    case False{}: char_kind_digit(code, Bool.and(U32.is_ge(code, 48), U32.is_le(code, 57)))

def char_kind_space(+code: U32, space: Bool, character: Char) -> CharKind:
  match space:
    case True{}: KSpace{}
    case False{}: char_kind_start(code, Bool.or(Char.is_alpha(character), U32.is_eq(code, 95)))

def char_kind(+character: Char) -> CharKind:
  match character:
    case Chr{code}:
      char_kind_space(code, Char.is_space(character), character)

def line_end(character: Char) -> Bool:
  match character:
    case Chr{+code}: Bool.or(U32.is_eq(code, 10), U32.is_eq(code, 13))

def chars_text(+chars: List<&2, Char>) -> String:
  String.from_list(List.reverse(&2, Char, chars))

def quoted_state(same_quote: Bool, quote: Char, character: Char, rest: String, chars: List<&2, Char>, tokens: List<&2, T.Token>) -> LexState:
  match same_quote:
    case True{}:
      text = chars_text(chars)
      Normal{rest, Con{T.TStringLiteral{text}, tokens}}
    case False{}:
      Quoted{quote, rest, Con{character, chars}, tokens}

def other_allowed_11(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 94), U32.is_eq(code, 124))

def other_allowed_10(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 93), other_allowed_11(code))

def other_allowed_9(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 91), other_allowed_10(code))

def other_allowed_8(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 64), other_allowed_9(code))

def other_allowed_7(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 62), other_allowed_8(code))

def other_allowed_6(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 60), other_allowed_7(code))

def other_allowed_5(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 47), other_allowed_6(code))

def other_allowed_4(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 45), other_allowed_5(code))

def other_allowed_3(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 42), other_allowed_4(code))

def other_allowed_2(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 38), other_allowed_3(code))

def other_allowed_1(+code: U32) -> Bool:
  Bool.or(U32.is_eq(code, 37), other_allowed_2(code))

def other_character_allowed(character: Char) -> Bool:
  match character:
    case Chr{+code}: Bool.or(U32.is_eq(code, 33), other_allowed_1(code))

def other_dispatch(allowed: Bool, +character: Char, rest: String, tokens: List<&2, T.Token>) -> LexState:
  match allowed:
    case True{}: Normal{rest, Con{T.TOther{character}, tokens}}
    case False{}: Invalid{character}

def word_from_chars(+chars: List<&2, Char>) -> T.Token:
  T.token_word(chars_text(chars))

def number_read_result(result: Maybe<&2, Nat>, text: String) -> T.LexResult:
  match result:
    case None{}: T.LexFailed{T.InvalidNumber{text}}
    case Some{value}: T.Lexed{Con{T.TIntLiteral{value}, Nil{}}}

def number_from_text(+text: String) -> T.LexResult:
  number_read_result(Nat.read(text), text)

def number_from_chars(+chars: List<&2, Char>) -> T.LexResult:
  number_from_text(chars_text(chars))

def append_token(token: T.Token, +tokens: List<&2, T.Token>) -> List<&2, T.Token>:
  Con{token, tokens}

def finish_number_result(result: Maybe<&2, Nat>, +tokens: List<&2, T.Token>) -> List<&2, T.Token>:
  match result:
    case None{}: tokens
    case Some{value}: Con{T.TIntLiteral{value}, tokens}

def finish_number_text(+text: String, +tokens: List<&2, T.Token>) -> List<&2, T.Token>:
  finish_number_result(Nat.read(text), tokens)

def finish_number(+chars: List<&2, Char>, +tokens: List<&2, T.Token>) -> List<&2, T.Token>:
  finish_number_text(chars_text(chars), tokens)

def lex_go(fuel: Nat, source: String, state: LexState) -> T.LexResult:
  match fuel:
    case 0n:
      T.LexFailed{T.LexStepLimit{}}
    case 1n+fuel_rest:
      match state:
        case Normal{remaining, tokens}:
          match remaining:
            case SNil{}:
              T.Lexed{List.reverse(&2, T.Token, Con{T.TEOF{}, tokens})}
            case SCon{+h, +t}:
              lex_go(fuel_rest, t, ClassifiedNormal{h, t, tokens, char_kind(h)})
        case Word{remaining, chars, tokens}:
          match remaining:
            case SNil{}:
              word = word_from_chars(chars)
              T.Lexed{List.reverse(&2, T.Token, Con{T.TEOF{}, Con{word, tokens}})}
            case SCon{+h, +t}:
              lex_go(fuel_rest, t, ClassifiedWord{h, t, chars, tokens, char_kind(h)})
        case Number{remaining, chars, tokens}:
          match remaining:
            case SNil{}:
              number_tokens = finish_number(chars, tokens)
              T.Lexed{List.reverse(&2, T.Token, Con{T.TEOF{}, number_tokens})}
            case SCon{+h, +t}:
              lex_go(fuel_rest, t, ClassifiedNumber{h, t, chars, tokens, char_kind(h)})
        case Quoted{quote, remaining, chars, tokens}:
          match remaining:
            case SNil{}:
              T.LexFailed{T.UnterminatedString{}}
            case SCon{+h, +t}:
              lex_go(fuel_rest, t, ClassifiedQuoted{h, t, chars, tokens, char_kind(h), quote})
        case Comment{remaining, tokens}:
          match remaining:
            case SNil{}:
              T.Lexed{List.reverse(&2, T.Token, Con{T.TEOF{}, tokens})}
            case SCon{+h, +t}:
              lex_go(fuel_rest, t, CommentClassified{h, t, tokens, line_end(h)})
        case Invalid{character}: T.LexFailed{T.InvalidCharacter{character}}
        case WordDone{character, +rest, chars, tokens}:
          word = word_from_chars(chars)
          lex_go(fuel_rest, rest, Dispatch{character, rest, Con{word, tokens}})
        case NumberDone{character, +rest, chars, tokens}:
          number_tokens = finish_number(chars, tokens)
          lex_go(fuel_rest, rest, Dispatch{character, rest, number_tokens})
        case Dispatch{+character, +rest, tokens}:
          lex_go(fuel_rest, rest, ClassifiedDispatch{character, rest, tokens, char_kind(character)})
        case ClassifiedNormal{character, +rest, tokens, kind}:
          match kind:
            case KSpace{}: lex_go(fuel_rest, rest, Normal{rest, tokens})
            case KIdentifierStart{}: lex_go(fuel_rest, rest, Word{rest, Con{character, Nil{}}, tokens})
            case KDigit{}: lex_go(fuel_rest, rest, Number{rest, Con{character, Nil{}}, tokens})
            case _: lex_go(fuel_rest, rest, Dispatch{character, rest, tokens})
        case ClassifiedWord{character, +rest, chars, tokens, kind}:
          match kind:
            case KIdentifierStart{}: lex_go(fuel_rest, rest, Word{rest, Con{character, chars}, tokens})
            case KDigit{}: lex_go(fuel_rest, rest, Word{rest, Con{character, chars}, tokens})
            case _: lex_go(fuel_rest, rest, WordDone{character, rest, chars, tokens})
        case ClassifiedNumber{character, +rest, chars, tokens, kind}:
          match kind:
            case KDigit{}: lex_go(fuel_rest, rest, Number{rest, Con{character, chars}, tokens})
            case KIdentifierStart{}: T.LexFailed{T.InvalidNumber{chars_text(chars)}}
            case _:
              number_tokens = finish_number(chars, tokens)
              lex_go(fuel_rest, rest, Dispatch{character, rest, number_tokens})
        case ClassifiedQuoted{+character, +rest, chars, tokens, kind, +quote}:
          match kind:
            case KQuote{}:
              lex_go(fuel_rest, rest, quoted_state(Char.is_eq(character, quote), quote, character, rest, chars, tokens))
            case _: lex_go(fuel_rest, rest, Quoted{quote, rest, Con{character, chars}, tokens})
        case CommentClassified{character, +rest, tokens, at_line_end}:
          match at_line_end:
            case True{}: lex_go(fuel_rest, rest, Normal{rest, tokens})
            case False{}: lex_go(fuel_rest, rest, Comment{rest, tokens})
        case ClassifiedDispatch{+character, +rest, tokens, kind}:
          match kind:
            case KSpace{}: lex_go(fuel_rest, rest, Normal{rest, tokens})
            case KQuote{}: lex_go(fuel_rest, rest, Quoted{character, rest, Nil{}, tokens})
            case KHash{}: lex_go(fuel_rest, rest, Comment{rest, tokens})
            case KDollar{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TDollar{}, tokens}})
            case KDot{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TDot{}, tokens}})
            case KComma{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TComma{}, tokens}})
            case KLBrace{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TLBrace{}, tokens}})
            case KRBrace{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TRBrace{}, tokens}})
            case KLParen{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TLParen{}, tokens}})
            case KRParen{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TRParen{}, tokens}})
            case KColon{}: lex_go(fuel_rest, rest, ColonDispatch{character, rest, tokens})
            case KEquals{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TEquals{}, tokens}})
            case KPlus{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TPlus{}, tokens}})
            case KSemicolon{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TSemicolon{}, tokens}})
            case KQuestion{}: lex_go(fuel_rest, rest, QuestionDispatch{character, rest, tokens})
            case _: lex_go(fuel_rest, rest, other_dispatch(other_character_allowed(character), character, rest, tokens))
        case ColonDispatch{character, +rest, tokens}:
          match rest:
            case SCon{+next, +tail}: lex_go(fuel_rest, tail, ColonClassified{character, rest, tokens, next, tail, char_kind(next)})
            case SNil{}: lex_go(fuel_rest, rest, Normal{rest, Con{T.TColon{}, tokens}})
        case ColonClassified{character, +rest, tokens, next, +tail, kind}:
          match kind:
            case KEquals{}: lex_go(fuel_rest, tail, Normal{tail, Con{T.TAssign{}, tokens}})
            case _: lex_go(fuel_rest, rest, Normal{rest, Con{T.TColon{}, tokens}})
        case QuestionDispatch{character, +rest, tokens}:
          match rest:
            case SCon{+next, +tail}: lex_go(fuel_rest, tail, QuestionClassified{character, rest, tokens, next, tail, char_kind(next)})
            case SNil{}: T.LexFailed{T.InvalidCharacter{character}}
        case QuestionClassified{character, +rest, tokens, next, +tail, kind}:
          match kind:
            case KQuestion{}: lex_go(fuel_rest, tail, Normal{tail, Con{T.TCoalesce{}, tokens}})
            case _: T.LexFailed{T.InvalidCharacter{character}}

def lex(+source: String) -> T.LexResult:
  lex_go(100000n, source, Normal{source, Nil{}})

def tokens_result(result: T.LexResult) -> List<&2, T.Token>:
  match result:
    case T.Lexed{tokens}: tokens
    case T.LexFailed{error}: Nil{}

def tokens(source: String) -> List<&2, T.Token>:
  tokens_result(lex(source))
