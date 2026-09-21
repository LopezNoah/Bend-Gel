import Base

# Tokens are deliberately independent from the core syntax.  The lexer keeps
# spelling and punctuation concerns here so the parser never has to inspect
# characters directly.
type Token is Data:
  TSelect{}
  TWith{}
  TFor{}
  TIn{}
  TUnion{}
  TFilter{}
  TOrder{}
  TBy{}
  TAsc{}
  TDesc{}
  TInsert{}
  TUpdate{}
  TSet{}
  TIdentifier{text: String}
  TStringLiteral{text: String}
  TIntLiteral{value: Nat}
  TDollar{}
  TDot{}
  TComma{}
  TLBrace{}
  TRBrace{}
  TLParen{}
  TRParen{}
  TColon{}
  TAssign{}
  TEquals{}
  TPlus{}
  TCoalesce{}
  TSemicolon{}
  TEOF{}

type LexError is Data:
  InvalidCharacter{character: Char}
  UnterminatedString{}
  InvalidNumber{text: String}
  LexStepLimit{}

type LexResult is Data:
  Lexed{tokens: List<&2, Token>}
  LexFailed{error: LexError}

def token_word(text: String) -> Token:
  match text:
    case "select": TSelect{}
    case "with": TWith{}
    case "for": TFor{}
    case "in": TIn{}
    case "union": TUnion{}
    case "filter": TFilter{}
    case "order": TOrder{}
    case "by": TBy{}
    case "asc": TAsc{}
    case "desc": TDesc{}
    case "insert": TInsert{}
    case "update": TUpdate{}
    case "set": TSet{}
    case _: TIdentifier{text}
