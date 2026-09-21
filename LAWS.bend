import Base
import ./Cardinality.bend as C

# Human-facing semantic contract for the Bend Gel prototype.
#
# These are identity laws of the paper's cardinality algebra: [0,0] is the
# identity for sequence union, and [1,1] is the identity for multiplication
# (the cardinality effect of a one-value for-body).
#
# The next expansion will add evaluator/refinement laws for deterministic
# union, unique synthesis, evaluation preservation, and store preservation.
# They remain absent until their executable relations are present: an open
# claim would make PROOF.bend fail rather than falsely report coverage.

law add_empty_left:
  for card: C.Card
  {C.add(C.CEmpty{}, card) == card : C.Card}

law multiply_one_left:
  for card: C.Card
  {C.mul(C.COne{}, card) == card : C.Card}

law add_empty_right:
  for card: C.Card
  {C.add(card, C.CEmpty{}) == card : C.Card}

law multiply_one_right:
  for card: C.Card
  {C.mul(card, C.COne{}) == card : C.Card}

law add_commutative:
  for a: C.Card
  for b: C.Card
  {C.add(a, b) == C.add(b, a) : C.Card}

law add_associative:
  for a: C.Card
  for b: C.Card
  for c: C.Card
  {C.add(C.add(a, b), c) == C.add(a, C.add(b, c)) : C.Card}

law multiply_associative:
  for a: C.Card
  for b: C.Card
  for c: C.Card
  {C.mul(C.mul(a, b), c) == C.mul(a, C.mul(b, c)) : C.Card}

law le_reflexive:
  for card: C.Card
  {C.le(card, card) == True{} : Bool}

law many_plus_one:
  {C.add(C.CMany{}, C.COne{}) == C.CNonEmptyMany{} : C.Card}