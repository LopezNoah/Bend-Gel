import Base

# The five modes from section 2.1 of "Querying Graph-Relational Data".
type Card is Data:
  CEmpty{}
  COptional{}
  COne{}
  CMany{}
  CNonEmptyMany{}

def add(a: Card, b: Card) -> Card:
  match a:
    case CEmpty{}:
      b
    case COptional{}:
      match b:
        case CEmpty{}: COptional{}
        case COptional{}: CMany{}
        case COne{}: CNonEmptyMany{}
        case CMany{}: CMany{}
        case CNonEmptyMany{}: CNonEmptyMany{}
    case COne{}:
      match b:
        case CEmpty{}: COne{}
        case COptional{}: CNonEmptyMany{}
        case COne{}: CNonEmptyMany{}
        case CMany{}: CNonEmptyMany{}
        case CNonEmptyMany{}: CNonEmptyMany{}
    case CMany{}:
      match b:
        case CEmpty{}: CMany{}
        case COptional{}: CMany{}
        case COne{}: CNonEmptyMany{}
        case CMany{}: CMany{}
        case CNonEmptyMany{}: CNonEmptyMany{}
    case CNonEmptyMany{}:
      match b:
        case CEmpty{}: CNonEmptyMany{}
        case COptional{}: CNonEmptyMany{}
        case COne{}: CNonEmptyMany{}
        case CMany{}: CNonEmptyMany{}
        case CNonEmptyMany{}: CNonEmptyMany{}

def mul(a: Card, b: Card) -> Card:
  match a:
    case CEmpty{}:
      CEmpty{}
    case COptional{}:
      match b:
        case CEmpty{}: CEmpty{}
        case COptional{}: COptional{}
        case COne{}: COptional{}
        case CMany{}: CMany{}
        case CNonEmptyMany{}: CMany{}
    case COne{}:
      b
    case CMany{}:
      match b:
        case CEmpty{}: CEmpty{}
        case COptional{}: CMany{}
        case COne{}: CMany{}
        case CMany{}: CMany{}
        case CNonEmptyMany{}: CMany{}
    case CNonEmptyMany{}:
      match b:
        case CEmpty{}: CEmpty{}
        case COptional{}: CMany{}
        case COne{}: CNonEmptyMany{}
        case CMany{}: CMany{}
        case CNonEmptyMany{}: CNonEmptyMany{}

# a <= b means every sequence admitted by a is admitted by b.
def le(a: Card, b: Card) -> Bool:
  match a:
    case CEmpty{}:
      match b:
        case CEmpty{}: True{}
        case COptional{}: True{}
        case COne{}: False{}
        case CMany{}: True{}
        case CNonEmptyMany{}: False{}
    case COptional{}:
      match b:
        case COptional{}: True{}
        case CMany{}: True{}
        case _: False{}
    case COne{}:
      match b:
        case CEmpty{}: False{}
        case COptional{}: True{}
        case COne{}: True{}
        case CMany{}: True{}
        case CNonEmptyMany{}: True{}
    case CMany{}:
      match b:
        case CMany{}: True{}
        case _: False{}
    case CNonEmptyMany{}:
      match b:
        case CMany{}: True{}
        case CNonEmptyMany{}: True{}
        case _: False{}

def card_eq(a: Card, b: Card) -> Bool:
  match a:
    case CEmpty{}:
      match b:
        case CEmpty{}: True{}
        case _: False{}
    case COptional{}:
      match b:
        case COptional{}: True{}
        case _: False{}
    case COne{}:
      match b:
        case COne{}: True{}
        case _: False{}
    case CMany{}:
      match b:
        case CMany{}: True{}
        case _: False{}
    case CNonEmptyMany{}:
      match b:
        case CNonEmptyMany{}: True{}
        case _: False{}

def implies(assumption: Bool, conclusion: Bool) -> Bool:
  match assumption:
    case True{}: conclusion
    case False{}: True{}

def nat_add(a: Nat, b: Nat) -> Nat:
  match a:
    case 0n: b
    case 1n+rest: (1n + nat_add(rest, b) : Nat)

def nat_mul(+a: Nat, +b: Nat) -> Nat:
  match a:
    case 0n: 0n
    case 1n+rest:
      match b:
        case 0n: 0n
        case 1n+other: nat_add(a, nat_mul(a, other))

def accepts(card: Card, n: Nat) -> Bool:
  match card:
    case CEmpty{}:
      match n:
        case 0n: True{}
        case 1n+p: False{}
    case COptional{}:
      match n:
        case 0n: True{}
        case 1n: True{}
        case 1n+p: False{}
    case COne{}:
      match n:
        case 0n: False{}
        case 1n: True{}
        case 1n+p: False{}
    case CMany{}:
      True{}
    case CNonEmptyMany{}:
      match n:
        case 0n: False{}
        case 1n+p: True{}

def accepts_add(+a: Card, +b: Card, +left_length: Nat, +right_length: Nat) -> Bool:
  left = accepts(a, left_length)
  right = accepts(b, right_length)
  premise = Bool.and(left, right)
  result = accepts(add(a, b), nat_add(left_length, right_length))
  implies(premise, result)

def accepts_mul(+a: Card, +b: Card, +left_length: Nat, +right_length: Nat) -> Bool:
  left = accepts(a, left_length)
  right = accepts(b, right_length)
  premise = Bool.and(left, right)
  result = accepts(mul(a, b), nat_mul(left_length, right_length))
  implies(premise, result)

def accepts_order_result(+lower: Card, +upper: Card, +length: Nat) -> Bool:
  ordered = le(lower, upper)
  premise = accepts(lower, length)
  result = accepts(upper, length)
  implies(ordered, implies(premise, result))

def accepts_order(+lower: Card, +upper: Card, +length: Nat) -> Bool:
  match lower upper:
    case CEmpty{} CEmpty{}: True{}
    case COptional{} COptional{}: True{}
    case COne{} COne{}: True{}
    case CMany{} CMany{}: True{}
    case CNonEmptyMany{} CNonEmptyMany{}: True{}
    case _ CMany{}: True{}
    case _ _: accepts_order_result(lower, upper, length)

def name(card: Card) -> String:
  match card:
    case CEmpty{}: "[0,0]"
    case COptional{}: "[0,1]"
    case COne{}: "[1,1]"
    case CMany{}: "[0,inf]"
    case CNonEmptyMany{}: "[1,inf]"
