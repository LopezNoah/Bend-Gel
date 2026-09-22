import Base
import ./LAWS.bend as Laws
import ./Cardinality.bend as C

# Proof-side obligations. Each finite-cardinality proof normalizes every
# possible constructor, leaving Bend to check the resulting reflexivity goal.
def Laws.add_empty_left(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.multiply_one_left(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.add_empty_right(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.multiply_one_right(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.multiply_empty_left(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.multiply_empty_right(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.le_reflexive(card):
  match card:
    case C.CEmpty{}: {==}
    case C.COptional{}: {==}
    case C.COne{}: {==}
    case C.CMany{}: {==}
    case C.CNonEmptyMany{}: {==}

def Laws.many_plus_one():
  {==}

def Laws.add_commutative(a, b):
  match a b:
    case C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{}: {==}
    case C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COne{}: {==}
    case C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{}: {==}
    case C.COne{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}

def Laws.add_associative(a, b, c):
  match a b c:
    case C.CEmpty{} _ _: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CEmpty{} _: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COptional{} C.COne{}: {==}
    case C.COptional{} C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COne{} C.CEmpty{}: {==}
    case C.COptional{} C.COne{} C.COptional{}: {==}
    case C.COptional{} C.COne{} C.COne{}: {==}
    case C.COptional{} C.COne{} C.CMany{}: {==}
    case C.COptional{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CMany{} C.COptional{}: {==}
    case C.COptional{} C.CMany{} C.COne{}: {==}
    case C.COptional{} C.CMany{} C.CMany{}: {==}
    case C.COptional{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{} _: {==}
    case C.COne{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COptional{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{} C.COptional{}: {==}
    case C.COne{} C.COptional{} C.COne{}: {==}
    case C.COne{} C.COptional{} C.CMany{}: {==}
    case C.COne{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{} C.COne{}: {==}
    case C.COne{} C.COne{} C.CMany{}: {==}
    case C.COne{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CMany{} C.CEmpty{}: {==}
    case C.COne{} C.CMany{} C.COptional{}: {==}
    case C.COne{} C.CMany{} C.COne{}: {==}
    case C.COne{} C.CMany{} C.CMany{}: {==}
    case C.COne{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CEmpty{} _: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COne{}: {==}
    case C.CMany{} C.COptional{} C.CMany{}: {==}
    case C.CMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COne{} C.CEmpty{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.CMany{}: {==}
    case C.CMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CMany{} C.CNonEmptyMany{}: {==}

def Laws.multiply_associative(a, b, c):
  match a b c:
    case C.CEmpty{} _ _: {==}
    case C.COptional{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COptional{} C.CEmpty{} C.COptional{}: {==}
    case C.COptional{} C.CEmpty{} C.COne{}: {==}
    case C.COptional{} C.CEmpty{} C.CMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COptional{} C.COne{}: {==}
    case C.COptional{} C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COne{} C.CEmpty{}: {==}
    case C.COptional{} C.COne{} C.COptional{}: {==}
    case C.COptional{} C.COne{} C.COne{}: {==}
    case C.COptional{} C.COne{} C.CMany{}: {==}
    case C.COptional{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CMany{} C.COptional{}: {==}
    case C.COptional{} C.CMany{} C.COne{}: {==}
    case C.COptional{} C.CMany{} C.CMany{}: {==}
    case C.COptional{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COne{} C.CEmpty{} C.COptional{}: {==}
    case C.COne{} C.CEmpty{} C.COne{}: {==}
    case C.COne{} C.CEmpty{} C.CMany{}: {==}
    case C.COne{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COptional{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{} C.COptional{}: {==}
    case C.COne{} C.COptional{} C.COne{}: {==}
    case C.COne{} C.COptional{} C.CMany{}: {==}
    case C.COne{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{} C.COne{}: {==}
    case C.COne{} C.COne{} C.CMany{}: {==}
    case C.COne{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CMany{} C.CEmpty{}: {==}
    case C.COne{} C.CMany{} C.COptional{}: {==}
    case C.COne{} C.CMany{} C.COne{}: {==}
    case C.COne{} C.CMany{} C.CMany{}: {==}
    case C.COne{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.COne{}: {==}
    case C.CMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COne{}: {==}
    case C.CMany{} C.COptional{} C.CMany{}: {==}
    case C.CMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COne{} C.CEmpty{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.CMany{}: {==}
    case C.CMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}

def Laws.multiply_commutative(a, b):
  match a b:
    case C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{}: {==}
    case C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COne{}: {==}
    case C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{}: {==}
    case C.COne{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}

def Laws.multiply_distributes_left(a, b, c):
  match a:
    case C.CEmpty{}: {==}
    case C.COne{}: {==}
    case C.COptional{}:
      match b c:
        case C.CEmpty{} C.CEmpty{}: {==}
        case C.CEmpty{} C.COptional{}: {==}
        case C.CEmpty{} C.COne{}: {==}
        case C.CEmpty{} C.CMany{}: {==}
        case C.CEmpty{} C.CNonEmptyMany{}: {==}
        case C.COptional{} C.CEmpty{}: {==}
        case C.COptional{} C.COptional{}: {==}
        case C.COptional{} C.COne{}: {==}
        case C.COptional{} C.CMany{}: {==}
        case C.COptional{} C.CNonEmptyMany{}: {==}
        case C.COne{} C.CEmpty{}: {==}
        case C.COne{} C.COptional{}: {==}
        case C.COne{} C.COne{}: {==}
        case C.COne{} C.CMany{}: {==}
        case C.COne{} C.CNonEmptyMany{}: {==}
        case C.CMany{} C.CEmpty{}: {==}
        case C.CMany{} C.COptional{}: {==}
        case C.CMany{} C.COne{}: {==}
        case C.CMany{} C.CMany{}: {==}
        case C.CMany{} C.CNonEmptyMany{}: {==}
        case C.CNonEmptyMany{} C.CEmpty{}: {==}
        case C.CNonEmptyMany{} C.COptional{}: {==}
        case C.CNonEmptyMany{} C.COne{}: {==}
        case C.CNonEmptyMany{} C.CMany{}: {==}
        case C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{}:
      match b c:
        case C.CEmpty{} C.CEmpty{}: {==}
        case C.CEmpty{} C.COptional{}: {==}
        case C.CEmpty{} C.COne{}: {==}
        case C.CEmpty{} C.CMany{}: {==}
        case C.CEmpty{} C.CNonEmptyMany{}: {==}
        case C.COptional{} C.CEmpty{}: {==}
        case C.COptional{} C.COptional{}: {==}
        case C.COptional{} C.COne{}: {==}
        case C.COptional{} C.CMany{}: {==}
        case C.COptional{} C.CNonEmptyMany{}: {==}
        case C.COne{} C.CEmpty{}: {==}
        case C.COne{} C.COptional{}: {==}
        case C.COne{} C.COne{}: {==}
        case C.COne{} C.CMany{}: {==}
        case C.COne{} C.CNonEmptyMany{}: {==}
        case C.CMany{} C.CEmpty{}: {==}
        case C.CMany{} C.COptional{}: {==}
        case C.CMany{} C.COne{}: {==}
        case C.CMany{} C.CMany{}: {==}
        case C.CMany{} C.CNonEmptyMany{}: {==}
        case C.CNonEmptyMany{} C.CEmpty{}: {==}
        case C.CNonEmptyMany{} C.COptional{}: {==}
        case C.CNonEmptyMany{} C.COne{}: {==}
        case C.CNonEmptyMany{} C.CMany{}: {==}
        case C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{}:
      match b c:
        case C.CEmpty{} C.CEmpty{}: {==}
        case C.CEmpty{} C.COptional{}: {==}
        case C.CEmpty{} C.COne{}: {==}
        case C.CEmpty{} C.CMany{}: {==}
        case C.CEmpty{} C.CNonEmptyMany{}: {==}
        case C.COptional{} C.CEmpty{}: {==}
        case C.COptional{} C.COptional{}: {==}
        case C.COptional{} C.COne{}: {==}
        case C.COptional{} C.CMany{}: {==}
        case C.COptional{} C.CNonEmptyMany{}: {==}
        case C.COne{} C.CEmpty{}: {==}
        case C.COne{} C.COptional{}: {==}
        case C.COne{} C.COne{}: {==}
        case C.COne{} C.CMany{}: {==}
        case C.COne{} C.CNonEmptyMany{}: {==}
        case C.CMany{} C.CEmpty{}: {==}
        case C.CMany{} C.COptional{}: {==}
        case C.CMany{} C.COne{}: {==}
        case C.CMany{} C.CMany{}: {==}
        case C.CMany{} C.CNonEmptyMany{}: {==}
        case C.CNonEmptyMany{} C.CEmpty{}: {==}
        case C.CNonEmptyMany{} C.COptional{}: {==}
        case C.CNonEmptyMany{} C.COne{}: {==}
        case C.CNonEmptyMany{} C.CMany{}: {==}
        case C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}

def Laws.accepts_order(lower, upper, length):
  match lower upper length:
    case C.CEmpty{} C.CEmpty{} 0n: {==}
    case C.CEmpty{} C.CEmpty{} 1n: {==}
    case C.CEmpty{} C.CEmpty{} 1n+1n+p: {==}
    case C.CEmpty{} C.COptional{} 0n: {==}
    case C.CEmpty{} C.COptional{} 1n: {==}
    case C.CEmpty{} C.COptional{} 1n+1n+p: {==}
    case C.CEmpty{} C.CMany{} 0n: {==}
    case C.CEmpty{} C.CMany{} 1n: {==}
    case C.CEmpty{} C.CMany{} 1n+1n+p: {==}
    case C.COptional{} C.COptional{} 0n: {==}
    case C.COptional{} C.COptional{} 1n: {==}
    case C.COptional{} C.COptional{} 1n+1n+p: {==}
    case C.COptional{} C.CMany{} 0n: {==}
    case C.COptional{} C.CMany{} 1n: {==}
    case C.COptional{} C.CMany{} 1n+1n+p: {==}
    case C.COne{} C.COptional{} 0n: {==}
    case C.COne{} C.COptional{} 1n: {==}
    case C.COne{} C.COptional{} 1n+1n+p: {==}
    case C.COne{} C.COne{} 0n: {==}
    case C.COne{} C.COne{} 1n: {==}
    case C.COne{} C.COne{} 1n+1n+p: {==}
    case C.COne{} C.CMany{} 0n: {==}
    case C.COne{} C.CMany{} 1n: {==}
    case C.COne{} C.CMany{} 1n+1n+p: {==}
    case C.COne{} C.CNonEmptyMany{} 0n: {==}
    case C.COne{} C.CNonEmptyMany{} 1n: {==}
    case C.COne{} C.CNonEmptyMany{} 1n+1n+p: {==}
    case C.CMany{} C.CMany{} _: {==}
    case C.CNonEmptyMany{} C.CMany{} 0n: {==}
    case C.CNonEmptyMany{} C.CMany{} 1n: {==}
    case C.CNonEmptyMany{} C.CMany{} 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 0n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p: {==}
    case C.CEmpty{} C.COne{} _: {==}
    case C.CEmpty{} C.CNonEmptyMany{} _: {==}
    case C.COptional{} C.CEmpty{} _: {==}
    case C.COptional{} C.COne{} _: {==}
    case C.COptional{} C.CNonEmptyMany{} _: {==}
    case C.COne{} C.CEmpty{} _: {==}
    case C.CMany{} C.CEmpty{} _: {==}
    case C.CMany{} C.COptional{} _: {==}
    case C.CMany{} C.COne{} _: {==}
    case C.CMany{} C.CNonEmptyMany{} _: {==}
    case C.CNonEmptyMany{} C.CEmpty{} _: {==}
    case C.CNonEmptyMany{} C.COptional{} _: {==}
    case C.CNonEmptyMany{} C.COne{} _: {==}

def Laws.accepts_add(a, b, left_length, right_length):
  match a b left_length right_length:
    case C.CEmpty{} _ 1n _: {==}
    case C.CEmpty{} _ 1n+1n+p _: {==}
    case C.COptional{} _ 1n+1n+p _: {==}
    case C.COne{} _ 0n _: {==}
    case C.COne{} _ 1n+1n+p _: {==}
    case C.CNonEmptyMany{} _ 0n _: {==}
    case C.CEmpty{} C.CEmpty{} 0n 1n: {==}
    case C.COptional{} C.CEmpty{} 0n 1n: {==}
    case C.COptional{} C.CEmpty{} 1n 1n: {==}
    case C.COne{} C.CEmpty{} 1n 1n: {==}
    case C.CMany{} C.CEmpty{} _ 1n: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n+1n+p 1n: {==}
    case C.CEmpty{} C.CEmpty{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CEmpty{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.COne{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.CMany{} C.CEmpty{} _ 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n+1n+p 1n+1n+p: {==}
    case C.CEmpty{} C.COptional{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COptional{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COptional{} 1n 1n+1n+p: {==}
    case C.COne{} C.COptional{} 1n 1n+1n+p: {==}
    case C.CMany{} C.COptional{} _ 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n+1n+p 1n+1n+p: {==}
    case C.CEmpty{} C.COne{} 0n 0n: {==}
    case C.COptional{} C.COne{} 0n 0n: {==}
    case C.COptional{} C.COne{} 1n 0n: {==}
    case C.COne{} C.COne{} 1n 0n: {==}
    case C.CMany{} C.COne{} _ 0n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n+1n+p 0n: {==}
    case C.CEmpty{} C.COne{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COne{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COne{} 1n 1n+1n+p: {==}
    case C.COne{} C.COne{} 1n 1n+1n+p: {==}
    case C.CMany{} C.COne{} _ 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COne{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COne{} 1n+1n+p 1n+1n+p: {==}
    case C.CEmpty{} C.CNonEmptyMany{} 0n 0n: {==}
    case C.COptional{} C.CNonEmptyMany{} 0n 0n: {==}
    case C.COptional{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.COne{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.CMany{} C.CNonEmptyMany{} _ 0n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p 0n: {==}
    case C.CEmpty{} C.CEmpty{} 0n 0n: {==}
    case C.CEmpty{} C.COptional{} 0n 0n: {==}
    case C.CEmpty{} C.COptional{} 0n 1n: {==}
    case C.CEmpty{} C.COne{} 0n 1n: {==}
    case C.CEmpty{} C.CMany{} 0n _: {==}
    case C.CEmpty{} C.CNonEmptyMany{} 0n 1n: {==}
    case C.CEmpty{} C.CNonEmptyMany{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CEmpty{} 0n 0n: {==}
    case C.COptional{} C.CEmpty{} 1n 0n: {==}
    case C.COptional{} C.COptional{} 0n 0n: {==}
    case C.COptional{} C.COptional{} 0n 1n: {==}
    case C.COptional{} C.COptional{} 1n 0n: {==}
    case C.COptional{} C.COptional{} 1n 1n: {==}
    case C.COptional{} C.COne{} 0n 1n: {==}
    case C.COptional{} C.COne{} 1n 1n: {==}
    case C.COptional{} C.CMany{} 0n _: {==}
    case C.COptional{} C.CMany{} 1n _: {==}
    case C.COptional{} C.CNonEmptyMany{} 0n 1n: {==}
    case C.COptional{} C.CNonEmptyMany{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.COptional{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.COne{} C.CEmpty{} 1n 0n: {==}
    case C.COne{} C.COptional{} 1n 0n: {==}
    case C.COne{} C.COptional{} 1n 1n: {==}
    case C.COne{} C.COne{} 1n 1n: {==}
    case C.COne{} C.CMany{} 1n _: {==}
    case C.COne{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.COne{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.CMany{} C.CEmpty{} _ 0n: {==}
    case C.CMany{} C.COptional{} _ 0n: {==}
    case C.CMany{} C.COptional{} _ 1n: {==}
    case C.CMany{} C.COne{} 0n 1n: {==}
    case C.CMany{} C.COne{} 1n 1n: {==}
    case C.CMany{} C.COne{} 1n+1n+p 1n: {==}
    case C.CMany{} C.CMany{} _ _: {==}
    case C.CMany{} C.CNonEmptyMany{} 0n 1n: {==}
    case C.CMany{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.CMany{} C.CNonEmptyMany{} 1n+1n+p 1n: {==}
    case C.CMany{} C.CNonEmptyMany{} 0n 1n+1n+p: {==}
    case C.CMany{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.CMany{} C.CNonEmptyMany{} 1n+1n+p 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n+1n+p 0n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n+1n+p 0n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.CMany{} 1n _: {==}
    case C.CNonEmptyMany{} C.CMany{} 1n+1n+p _: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p 1n+1n+p: {==}

def Laws.accepts_mul(a, b, left_length, right_length):
  match a b left_length right_length:
    case C.CEmpty{} _ 1n _: {==}
    case C.CEmpty{} _ 1n+1n+p _: {==}
    case C.COptional{} _ 1n+1n+p _: {==}
    case C.COne{} _ 0n _: {==}
    case C.COne{} _ 1n+1n+p _: {==}
    case C.CNonEmptyMany{} _ 0n _: {==}
    case C.CEmpty{} C.CEmpty{} 0n 1n: {==}
    case C.COptional{} C.CEmpty{} 0n 1n: {==}
    case C.COptional{} C.CEmpty{} 1n 1n: {==}
    case C.COne{} C.CEmpty{} 1n 1n: {==}
    case C.CMany{} C.CEmpty{} 0n 1n: {==}
    case C.CMany{} C.CEmpty{} 1n 1n: {==}
    case C.CMany{} C.CEmpty{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n+1n+p 1n: {==}
    case C.CEmpty{} C.CEmpty{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CEmpty{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.COne{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.CMany{} C.CEmpty{} 0n 1n+1n+p: {==}
    case C.CMany{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.CMany{} C.CEmpty{} 1n+1n+p 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n+1n+p 1n+1n+p: {==}
    case C.CEmpty{} C.COptional{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COptional{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COptional{} 1n 1n+1n+p: {==}
    case C.COne{} C.COptional{} 1n 1n+1n+p: {==}
    case C.CMany{} C.COptional{} 0n 1n+1n+p: {==}
    case C.CMany{} C.COptional{} 1n 1n+1n+p: {==}
    case C.CMany{} C.COptional{} 1n+1n+p 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n+1n+p 1n+1n+p: {==}
    case C.CEmpty{} C.COne{} 0n 0n: {==}
    case C.COptional{} C.COne{} 0n 0n: {==}
    case C.COptional{} C.COne{} 1n 0n: {==}
    case C.COne{} C.COne{} 1n 0n: {==}
    case C.CMany{} C.COne{} 0n 0n: {==}
    case C.CMany{} C.COne{} 1n 0n: {==}
    case C.CMany{} C.COne{} 1n+1n+p 0n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n+1n+p 0n: {==}
    case C.CEmpty{} C.COne{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COne{} 0n 1n+1n+p: {==}
    case C.COptional{} C.COne{} 1n 1n+1n+p: {==}
    case C.COne{} C.COne{} 1n 1n+1n+p: {==}
    case C.CMany{} C.COne{} 0n 1n+1n+p: {==}
    case C.CMany{} C.COne{} 1n 1n+1n+p: {==}
    case C.CMany{} C.COne{} 1n+1n+p 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COne{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.COne{} 1n+1n+p 1n+1n+p: {==}
    case C.CEmpty{} C.CNonEmptyMany{} 0n 0n: {==}
    case C.COptional{} C.CNonEmptyMany{} 0n 0n: {==}
    case C.COptional{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.COne{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.CMany{} C.CNonEmptyMany{} 0n 0n: {==}
    case C.CMany{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.CMany{} C.CNonEmptyMany{} 1n+1n+p 0n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p 0n: {==}
    case C.CEmpty{} C.CEmpty{} 0n 0n: {==}
    case C.CEmpty{} C.COptional{} 0n 0n: {==}
    case C.CEmpty{} C.COptional{} 0n 1n: {==}
    case C.CEmpty{} C.COne{} 0n 1n: {==}
    case C.CEmpty{} C.CMany{} 0n _: {==}
    case C.CEmpty{} C.CNonEmptyMany{} 0n 1n: {==}
    case C.CEmpty{} C.CNonEmptyMany{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CEmpty{} 0n 0n: {==}
    case C.COptional{} C.CEmpty{} 1n 0n: {==}
    case C.COptional{} C.COptional{} 0n 0n: {==}
    case C.COptional{} C.COptional{} 0n 1n: {==}
    case C.COptional{} C.COptional{} 1n 0n: {==}
    case C.COptional{} C.COptional{} 1n 1n: {==}
    case C.COptional{} C.COne{} 0n 1n: {==}
    case C.COptional{} C.COne{} 1n 1n: {==}
    case C.COptional{} C.CMany{} 0n _: {==}
    case C.COptional{} C.CMany{} 1n _: {==}
    case C.COptional{} C.CNonEmptyMany{} 0n 1n: {==}
    case C.COptional{} C.CNonEmptyMany{} 0n 1n+1n+p: {==}
    case C.COptional{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.COptional{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.COne{} C.CEmpty{} 1n 0n: {==}
    case C.COne{} C.COptional{} 1n 0n: {==}
    case C.COne{} C.COptional{} 1n 1n: {==}
    case C.COne{} C.COne{} 1n 1n: {==}
    case C.COne{} C.CMany{} 1n _: {==}
    case C.COne{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.COne{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.CMany{} C.CEmpty{} 0n 0n: {==}
    case C.CMany{} C.CEmpty{} 1n 0n: {==}
    case C.CMany{} C.CEmpty{} 1n+1n+p 0n: {==}
    case C.CMany{} C.COptional{} _ 0n: {==}
    case C.CMany{} C.COptional{} _ 1n: {==}
    case C.CMany{} C.COne{} _ 1n: {==}
    case C.CMany{} C.CMany{} _ _: {==}
    case C.CMany{} C.CNonEmptyMany{} _ 1n: {==}
    case C.CMany{} C.CNonEmptyMany{} _ 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.CEmpty{} 1n+1n+p 0n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n 0n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n+1n+p 0n: {==}
    case C.CNonEmptyMany{} C.COptional{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.COne{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.CMany{} 1n _: {==}
    case C.CNonEmptyMany{} C.CMany{} 1n+1n+p _: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n 1n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n 1n+1n+p: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p 1n: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} 1n+1n+p 1n+1n+p: {==}

def Laws.add_monotone(a, b, c):
  match a b c:
    case C.CEmpty{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COptional{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COne{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CEmpty{} C.COptional{}: {==}
    case C.COptional{} C.CEmpty{} C.COptional{}: {==}
    case C.COne{} C.CEmpty{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.CEmpty{} C.CMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CMany{}: {==}
    case C.COne{} C.CEmpty{} C.CMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COptional{} C.COptional{}: {==}
    case C.COne{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CEmpty{} C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.COptional{} C.CMany{}: {==}
    case C.COne{} C.COptional{} C.CMany{}: {==}
    case C.CMany{} C.COptional{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CMany{}: {==}
    case C.CEmpty{} C.COne{} C.COptional{}: {==}
    case C.COptional{} C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{} C.COne{}: {==}
    case C.COptional{} C.COne{} C.COne{}: {==}
    case C.COne{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CEmpty{} C.COne{} C.CMany{}: {==}
    case C.COptional{} C.COne{} C.CMany{}: {==}
    case C.COne{} C.COne{} C.CMany{}: {==}
    case C.CMany{} C.COne{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CMany{}: {==}
    case C.CEmpty{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CMany{} C.CMany{}: {==}
    case C.COptional{} C.CMany{} C.CMany{}: {==}
    case C.COne{} C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case _ C.CEmpty{} C.COne{}: {==}
    case _ C.CEmpty{} C.CNonEmptyMany{}: {==}
    case _ C.COptional{} C.CEmpty{}: {==}
    case _ C.COptional{} C.COne{}: {==}
    case _ C.COptional{} C.CNonEmptyMany{}: {==}
    case _ C.COne{} C.CEmpty{}: {==}
    case _ C.CMany{} C.CEmpty{}: {==}
    case _ C.CMany{} C.COptional{}: {==}
    case _ C.CMany{} C.COne{}: {==}
    case _ C.CMany{} C.CNonEmptyMany{}: {==}
    case _ C.CNonEmptyMany{} C.CEmpty{}: {==}
    case _ C.CNonEmptyMany{} C.COptional{}: {==}
    case _ C.CNonEmptyMany{} C.COne{}: {==}

def Laws.multiply_monotone(a, b, c):
  match a b c:
    case C.CEmpty{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COptional{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COne{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CEmpty{} C.COptional{}: {==}
    case C.COptional{} C.CEmpty{} C.COptional{}: {==}
    case C.COne{} C.CEmpty{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.CEmpty{} C.CMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CMany{}: {==}
    case C.COne{} C.CEmpty{} C.CMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COptional{} C.COptional{}: {==}
    case C.COne{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CEmpty{} C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.COptional{} C.CMany{}: {==}
    case C.COne{} C.COptional{} C.CMany{}: {==}
    case C.CMany{} C.COptional{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CMany{}: {==}
    case C.CEmpty{} C.COne{} C.COptional{}: {==}
    case C.COptional{} C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{} C.COne{}: {==}
    case C.COptional{} C.COne{} C.COne{}: {==}
    case C.COne{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CEmpty{} C.COne{} C.CMany{}: {==}
    case C.COptional{} C.COne{} C.CMany{}: {==}
    case C.COne{} C.COne{} C.CMany{}: {==}
    case C.CMany{} C.COne{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CMany{}: {==}
    case C.CEmpty{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CMany{} C.CMany{}: {==}
    case C.COptional{} C.CMany{} C.CMany{}: {==}
    case C.COne{} C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case _ C.CEmpty{} C.COne{}: {==}
    case _ C.CEmpty{} C.CNonEmptyMany{}: {==}
    case _ C.COptional{} C.CEmpty{}: {==}
    case _ C.COptional{} C.COne{}: {==}
    case _ C.COptional{} C.CNonEmptyMany{}: {==}
    case _ C.COne{} C.CEmpty{}: {==}
    case _ C.CMany{} C.CEmpty{}: {==}
    case _ C.CMany{} C.COptional{}: {==}
    case _ C.CMany{} C.COne{}: {==}
    case _ C.CMany{} C.CNonEmptyMany{}: {==}
    case _ C.CNonEmptyMany{} C.CEmpty{}: {==}
    case _ C.CNonEmptyMany{} C.COptional{}: {==}
    case _ C.CNonEmptyMany{} C.COne{}: {==}

def Laws.le_transitive(a, b, c):
  match a b c:
    case C.CEmpty{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.CEmpty{} C.COne{}: {==}
    case C.CEmpty{} C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.COptional{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COptional{} C.COptional{}: {==}
    case C.CEmpty{} C.COptional{} C.COne{}: {==}
    case C.CEmpty{} C.COptional{} C.CMany{}: {==}
    case C.CEmpty{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.COne{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COne{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{} C.COne{}: {==}
    case C.CEmpty{} C.COne{} C.CMany{}: {==}
    case C.CEmpty{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CMany{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CMany{} C.COptional{}: {==}
    case C.CEmpty{} C.CMany{} C.COne{}: {==}
    case C.CEmpty{} C.CMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COptional{} C.CEmpty{} C.COptional{}: {==}
    case C.COptional{} C.CEmpty{} C.COne{}: {==}
    case C.COptional{} C.CEmpty{} C.CMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COptional{} C.COne{}: {==}
    case C.COptional{} C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COne{} C.CEmpty{}: {==}
    case C.COptional{} C.COne{} C.COptional{}: {==}
    case C.COptional{} C.COne{} C.COne{}: {==}
    case C.COptional{} C.COne{} C.CMany{}: {==}
    case C.COptional{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CMany{} C.COptional{}: {==}
    case C.COptional{} C.CMany{} C.COne{}: {==}
    case C.COptional{} C.CMany{} C.CMany{}: {==}
    case C.COptional{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COne{} C.CEmpty{} C.COptional{}: {==}
    case C.COne{} C.CEmpty{} C.COne{}: {==}
    case C.COne{} C.CEmpty{} C.CMany{}: {==}
    case C.COne{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COptional{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{} C.COptional{}: {==}
    case C.COne{} C.COptional{} C.COne{}: {==}
    case C.COne{} C.COptional{} C.CMany{}: {==}
    case C.COne{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{} C.COne{}: {==}
    case C.COne{} C.COne{} C.CMany{}: {==}
    case C.COne{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CMany{} C.CEmpty{}: {==}
    case C.COne{} C.CMany{} C.COptional{}: {==}
    case C.COne{} C.CMany{} C.COne{}: {==}
    case C.COne{} C.CMany{} C.CMany{}: {==}
    case C.COne{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.COne{}: {==}
    case C.CMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COne{}: {==}
    case C.CMany{} C.COptional{} C.CMany{}: {==}
    case C.CMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COne{} C.CEmpty{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.CMany{}: {==}
    case C.CMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}

def Laws.le_antisymmetric(a, b):
  match a b:
    case C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{}: {==}
    case C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COne{}: {==}
    case C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{}: {==}
    case C.COne{} C.COne{}: {==}
    case C.COne{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}

def Laws.multiply_distributes_right(a, b, c):
  match a b c:
    case C.CEmpty{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COptional{} C.CEmpty{}: {==}
    case C.CEmpty{} C.COne{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CMany{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COptional{} C.COptional{} C.CEmpty{}: {==}
    case C.COptional{} C.COne{} C.CEmpty{}: {==}
    case C.COptional{} C.CMany{} C.CEmpty{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.COne{} C.CEmpty{} C.CEmpty{}: {==}
    case C.COne{} C.COptional{} C.CEmpty{}: {==}
    case C.COne{} C.COne{} C.CEmpty{}: {==}
    case C.COne{} C.CMany{} C.CEmpty{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CMany{} C.COne{} C.CEmpty{}: {==}
    case C.CMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CEmpty{} C.CEmpty{} C.COne{}: {==}
    case C.CEmpty{} C.COptional{} C.COne{}: {==}
    case C.CEmpty{} C.COne{} C.COne{}: {==}
    case C.CEmpty{} C.CMany{} C.COne{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COptional{} C.CEmpty{} C.COne{}: {==}
    case C.COptional{} C.COptional{} C.COne{}: {==}
    case C.COptional{} C.COne{} C.COne{}: {==}
    case C.COptional{} C.CMany{} C.COne{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.COne{} C.CEmpty{} C.COne{}: {==}
    case C.COne{} C.COptional{} C.COne{}: {==}
    case C.COne{} C.COne{} C.COne{}: {==}
    case C.COne{} C.CMany{} C.COne{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CMany{} C.CEmpty{} C.COne{}: {==}
    case C.CMany{} C.COptional{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CEmpty{} C.CEmpty{} C.CMany{}: {==}
    case C.CEmpty{} C.COptional{} C.CMany{}: {==}
    case C.CEmpty{} C.COne{} C.CMany{}: {==}
    case C.CEmpty{} C.CMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CMany{}: {==}
    case C.COptional{} C.COptional{} C.CMany{}: {==}
    case C.COptional{} C.COne{} C.CMany{}: {==}
    case C.COptional{} C.CMany{} C.CMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.COne{} C.CEmpty{} C.CMany{}: {==}
    case C.COne{} C.COptional{} C.CMany{}: {==}
    case C.COne{} C.COne{} C.CMany{}: {==}
    case C.COne{} C.CMany{} C.CMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CEmpty{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CEmpty{} C.CEmpty{} C.COptional{}: {==}
    case C.CEmpty{} C.COptional{} C.COptional{}: {==}
    case C.CEmpty{} C.COne{} C.COptional{}: {==}
    case C.CEmpty{} C.CMany{} C.COptional{}: {==}
    case C.CEmpty{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COptional{} C.CEmpty{} C.COptional{}: {==}
    case C.COptional{} C.COptional{} C.COptional{}: {==}
    case C.COptional{} C.COne{} C.COptional{}: {==}
    case C.COptional{} C.CMany{} C.COptional{}: {==}
    case C.COptional{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.COne{} C.CEmpty{} C.COptional{}: {==}
    case C.COne{} C.COptional{} C.COptional{}: {==}
    case C.COne{} C.COne{} C.COptional{}: {==}
    case C.COne{} C.CMany{} C.COptional{}: {==}
    case C.COne{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CMany{} C.CEmpty{} C.COne{}: {==}
    case C.CMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CMany{} C.COptional{} C.COptional{}: {==}
    case C.CMany{} C.COptional{} C.COne{}: {==}
    case C.CMany{} C.COptional{} C.CMany{}: {==}
    case C.CMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.COne{} C.CEmpty{}: {==}
    case C.CMany{} C.COne{} C.COptional{}: {==}
    case C.CMany{} C.COne{} C.COne{}: {==}
    case C.CMany{} C.COne{} C.CMany{}: {==}
    case C.CMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CMany{} C.COptional{}: {==}
    case C.CMany{} C.CMany{} C.COne{}: {==}
    case C.CMany{} C.CMany{} C.CMany{}: {==}
    case C.CMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CEmpty{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COptional{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.COne{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CMany{} C.CNonEmptyMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CEmpty{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COptional{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.COne{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CMany{}: {==}
    case C.CNonEmptyMany{} C.CNonEmptyMany{} C.CNonEmptyMany{}: {==}
