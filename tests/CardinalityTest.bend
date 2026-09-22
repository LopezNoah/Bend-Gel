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

def multiply_empty_left_is_empty() -> {
  C.mul(C.CEmpty{}, C.CNonEmptyMany{}) == C.CEmpty{} : C.Card
}:
  {==}

def multiply_empty_right_is_empty() -> {
  C.mul(C.CMany{}, C.CEmpty{}) == C.CEmpty{} : C.Card
}:
  {==}

def multiply_distributes_left_regression() -> {
  C.mul(C.COptional{}, C.add(C.COne{}, C.CMany{})) == C.add(C.mul(C.COptional{}, C.COne{}), C.mul(C.COptional{}, C.CMany{})) : C.Card
}:
  {==}

def multiply_distributes_right_regression() -> {
  C.mul(C.add(C.CMany{}, C.COptional{}), C.CNonEmptyMany{}) == C.add(C.mul(C.CMany{}, C.CNonEmptyMany{}), C.mul(C.COptional{}, C.CNonEmptyMany{})) : C.Card
}:
  {==}

def acceptance_boundaries() -> Bool:
  empty = Bool.and(C.accepts(C.CEmpty{}, 0n), Bool.not(C.accepts(C.CEmpty{}, 1n)))
  optional = Bool.and(C.accepts(C.COptional{}, 0n), Bool.not(C.accepts(C.COptional{}, 2n)))
  one = Bool.and(C.accepts(C.COne{}, 1n), Bool.not(C.accepts(C.COne{}, 0n)))
  non_empty = Bool.and(Bool.not(C.accepts(C.CNonEmptyMany{}, 0n)), C.accepts(C.CNonEmptyMany{}, 2n))
  Bool.and(empty, Bool.and(optional, Bool.and(one, non_empty)))

def ordering_boundaries() -> Bool:
  empty_to_optional = C.le(C.CEmpty{}, C.COptional{})
  optional_to_many = C.le(C.COptional{}, C.CMany{})
  one_to_non_empty = C.le(C.COne{}, C.CNonEmptyMany{})
  optional_not_one = Bool.not(C.le(C.COptional{}, C.COne{}))
  same_card = C.card_eq(C.CNonEmptyMany{}, C.CNonEmptyMany{})
  Bool.and(empty_to_optional, Bool.and(optional_to_many, Bool.and(one_to_non_empty, Bool.and(optional_not_one, same_card))))

def membership_operations() -> Bool:
  added = C.accepts_add(C.COptional{}, C.COne{}, 1n, 1n)
  added_many = C.accepts_add(C.CEmpty{}, C.CMany{}, 0n, 3n)
  multiplied = C.accepts_mul(C.COptional{}, C.CNonEmptyMany{}, 1n, 2n)
  multiplied_one = C.accepts_mul(C.COne{}, C.CNonEmptyMany{}, 1n, 2n)
  multiplied_empty = C.accepts_mul(C.CMany{}, C.CEmpty{}, 3n, 0n)
  multiplied_many = C.accepts_mul(C.CMany{}, C.COne{}, 3n, 1n)
  Bool.and(added, Bool.and(added_many, Bool.and(multiplied, Bool.and(multiplied_one, Bool.and(multiplied_empty, multiplied_many)))))

def main() -> Bool:
  a = C.add(C.COptional{}, C.COne{})
  b = C.mul(C.CNonEmptyMany{}, C.COptional{})
  c = C.le(C.COne{}, C.COptional{})
  d = C.accepts(C.COptional{}, 2n)
  Bool.and(check(a, b, c, d), Bool.and(acceptance_boundaries(), Bool.and(ordering_boundaries(), membership_operations())))
