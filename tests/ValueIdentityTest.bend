import Base
import ../src/Syntax.bend as S
import ../src/Value.bend as V

def main() -> Bool:
  +bob = {V.CVScalar{S.VString{"Bob"}} : V.ComputedValue}
  V.value_identity_equal(bob, bob)
