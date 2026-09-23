import Base
import ../Cardinality.bend as C

# Independent interval oracle for the five modes in Section 2.1 of
# https://arxiv.org/html/2507.16089#S2.SS1. Upper bounds are 0, 1, or infinity;
# lower bounds are 0 or 1. This does not use the implementation's tables.
type Upper is Data:
  UpperZero{}
  UpperOne{}
  UpperInfinite{}

def lower(card: C.Card) -> Nat:
  match card:
    case C.CEmpty{}: 0n
    case C.COptional{}: 0n
    case C.COne{}: 1n
    case C.CMany{}: 0n
    case C.CNonEmptyMany{}: 1n

def upper(card: C.Card) -> Upper:
  match card:
    case C.CEmpty{}: UpperZero{}
    case C.COptional{}: UpperOne{}
    case C.COne{}: UpperOne{}
    case C.CMany{}: UpperInfinite{}
    case C.CNonEmptyMany{}: UpperInfinite{}

def upper_rank(bound: Upper) -> Nat:
  match bound:
    case UpperZero{}: 0n
    case UpperOne{}: 1n
    case UpperInfinite{}: 2n

def from_bounds(minimum: Nat, ceiling: Upper) -> C.Card:
  match minimum ceiling:
    case _ UpperZero{}: C.CEmpty{}
    case 0n UpperOne{}: C.COptional{}
    case 1n+p UpperOne{}: C.COne{}
    case 0n UpperInfinite{}: C.CMany{}
    case 1n+p UpperInfinite{}: C.CNonEmptyMany{}

def upper_sum(a: Upper, b: Upper) -> Upper:
  match a b:
    case UpperZero{} other: other
    case other UpperZero{}: other
    case UpperOne{} UpperOne{}: UpperInfinite{}
    case UpperInfinite{} _: UpperInfinite{}
    case _ UpperInfinite{}: UpperInfinite{}

def upper_product(a: Upper, b: Upper) -> Upper:
  match a b:
    case UpperZero{} _: UpperZero{}
    case _ UpperZero{}: UpperZero{}
    case UpperOne{} other: other
    case other UpperOne{}: other
    case UpperInfinite{} UpperInfinite{}: UpperInfinite{}

def rounded_sum(sum: Nat, left: Upper, right: Upper) -> C.Card:
  match sum:
    case 0n: from_bounds(0n, upper_sum(left, right))
    case 1n+p: from_bounds(1n, upper_sum(left, right))

def expected_add(+a: C.Card, +b: C.Card) -> C.Card:
  rounded_sum((lower(a) + lower(b) : Nat), upper(a), upper(b))

def expected_mul(+a: C.Card, +b: C.Card) -> C.Card:
  from_bounds((lower(a) * lower(b) : Nat), upper_product(upper(a), upper(b)))

def expected_le(+a: C.Card, +b: C.Card) -> Bool:
  Bool.and(Nat.is_le(lower(b), lower(a)), Nat.is_le(upper_rank(upper(a)), upper_rank(upper(b))))

def accepts_bounds(ceiling: Upper, minimum: Nat, +length: Nat) -> Bool:
  match ceiling:
    case UpperInfinite{}: Nat.is_le(minimum, length)
    case bound:
      Bool.and(Nat.is_le(minimum, length), Nat.is_le(length, upper_rank(bound)))

def expected_accepts(+card: C.Card, length: Nat) -> Bool:
  accepts_bounds(upper(card), lower(card), length)

def bool_equal(a: Bool, b: Bool) -> Bool:
  match a b:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _ _: False{}

def check_pair(+a: C.Card, +b: C.Card) -> Bool:
  sum_ok = C.card_eq(C.add(a, b), expected_add(a, b))
  product_ok = C.card_eq(C.mul(a, b), expected_mul(a, b))
  order_ok = bool_equal(C.le(a, b), expected_le(a, b))
  Bool.and(sum_ok, Bool.and(product_ok, order_ok))

def check_row(+a: C.Card, cards: List<&2, C.Card>) -> Bool:
  match cards:
    case Nil{}: True{}
    case Con{b, rest}: Bool.and(check_pair(a, b), check_row(a, rest))

def check_pairs(cards: List<&2, C.Card>, +all_cards: List<&2, C.Card>) -> Bool:
  match cards:
    case Nil{}: True{}
    case Con{a, rest}: Bool.and(check_row(a, all_cards), check_pairs(rest, all_cards))

def check_lengths(+card: C.Card) -> Bool:
  zero = bool_equal(C.accepts(card, 0n), expected_accepts(card, 0n))
  one = bool_equal(C.accepts(card, 1n), expected_accepts(card, 1n))
  two = bool_equal(C.accepts(card, 2n), expected_accepts(card, 2n))
  many = bool_equal(C.accepts(card, 4n), expected_accepts(card, 4n))
  Bool.and(zero, Bool.and(one, Bool.and(two, many)))

def check_all_lengths(cards: List<&2, C.Card>) -> Bool:
  match cards:
    case Nil{}: True{}
    case Con{card, rest}: Bool.and(check_lengths(card), check_all_lengths(rest))

def result(ok: Bool) -> IO(Unit):
  match ok:
    case True{}: IO.pure(Unit, Unit{})
    case False{}: IO.die(Unit, 1, "cardinality tables disagree with interval bounds")

def main() -> IO(Unit):
  +cards = {[C.CEmpty{}, C.COptional{}, C.COne{}, C.CMany{}, C.CNonEmptyMany{}] : List<&2, C.Card>}
  result(Bool.and(check_pairs(cards, cards), check_all_lengths(cards)))
