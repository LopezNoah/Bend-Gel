import Base
import ./LAWS.bend as Laws
import ./Cardinality.bend as C

# Proof-side obligations. The Bend checker compares these definitions with
# the contracts in LAWS.bend.
def Laws.add_empty_left(card):
  {==}

def Laws.multiply_one_left(card):
  {==}
