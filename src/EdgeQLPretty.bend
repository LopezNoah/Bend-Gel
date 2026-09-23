import Base
import ./EdgeQLSyntax.bend as E
import ./EdgeQLToken.bend as T

# A deliberately small, depth-bounded surface grammar. Each constructor
# chooses one AST form, and Atom selects its variable leaf. The printer is
# canonical only for expressions represented by this type.
type Atom is Data:
  One{}
  Two{}

type CanonicalExpr is Data:
  Atomic{value: Atom}
  Addition{right: Atom}
  Call{argument: Atom}
  GroupedUnionAdd{addend: Atom}

def atom_expr(value: Atom) -> E.SurfaceExpr:
  match value:
    case One{}: E.SLiteral{E.LInt{1n}}
    case Two{}: E.SLiteral{E.LInt{2n}}

def atom_text(value: Atom) -> String:
  match value:
    case One{}: "1"
    case Two{}: "2"

def to_surface(expr: CanonicalExpr) -> E.SurfaceExpr:
  match expr:
    case Atomic{value}: atom_expr(value)
    case Addition{right}: E.SAdd{E.SLiteral{E.LInt{1n}}, atom_expr(right)}
    case Call{argument}:
      E.SCall{E.Name{"add"}, [E.SLiteral{E.LInt{1n}}, atom_expr(argument)]}
    case GroupedUnionAdd{addend}:
      E.SAdd{E.SUnion{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, atom_expr(addend)}

def atom_token(value: Atom) -> T.Token:
  match value:
    case One{}: T.TIntLiteral{1n}
    case Two{}: T.TIntLiteral{2n}

# Canonical token stream, including the EOF required by Parser.parse.
def pretty(expr: CanonicalExpr) -> List<&2, T.Token>:
  match expr:
    case Atomic{value}: [atom_token(value), T.TEOF{}]
    case Addition{right}: [T.TIntLiteral{1n}, T.TPlus{}, atom_token(right), T.TEOF{}]
    case Call{argument}: [T.TIdentifier{"add"}, T.TLParen{}, T.TIntLiteral{1n}, T.TComma{}, atom_token(argument), T.TRParen{}, T.TEOF{}]
    case GroupedUnionAdd{addend}:
      [T.TLParen{}, T.TIntLiteral{1n}, T.TUnion{}, T.TIntLiteral{2n}, T.TRParen{}, T.TPlus{}, atom_token(addend), T.TEOF{}]

# Textual spelling of the same subset, checked through the lexer at runtime.
def source(expr: CanonicalExpr) -> String:
  match expr:
    case Atomic{value}: atom_text(value)
    case Addition{right}: "1 + " ++ atom_text(right)
    case Call{argument}: "add(1, " ++ atom_text(argument) ++ ")"
    case GroupedUnionAdd{addend}: "(1 union 2) + " ++ atom_text(addend)
