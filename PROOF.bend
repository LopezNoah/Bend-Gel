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
