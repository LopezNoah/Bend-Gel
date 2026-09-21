import Base
import ../Cardinality.bend as C

def check(a: C.Card, b: C.Card, c: Bool, d: Bool) -> Bool:
  match a:
    case C.CNonEmptyMany{}:
      match b:
        case C.CMany{}:
          match c:
            case True{}:
              match d:
                case False{}:
                  True{}
                case True{}:
                  False{}
            case False{}:
              False{}
        case _:
          False{}
    case _:
      False{}

def many_plus_one_regression() -> {
  C.add(C.CMany{}, C.COne{}) == C.CNonEmptyMany{} : C.Card
}:
  {==}

def many_plus_non_empty_many_regression() -> {
  C.add(C.CMany{}, C.CNonEmptyMany{}) == C.CNonEmptyMany{} : C.Card
}:
  {==}

def many_plus_one_is_commutative() -> {
  C.add(C.CMany{}, C.COne{}) == C.add(C.COne{}, C.CMany{}) : C.Card
}:
  {==}

def main() -> Bool:
  a = C.add(C.COptional{}, C.COne{})
  b = C.mul(C.CNonEmptyMany{}, C.COptional{})
  c = C.le(C.COne{}, C.COptional{})
  d = C.accepts(C.COptional{}, 2n)
  check(a, b, c, d)