import Base
import ../src/Syntax.bend as S
import ../src/Value.bend as V

def main() -> Bool:
  +bob = {V.CVScalar{S.VString{"Bob"}} : V.ComputedValue}
  +alice = {V.CVScalar{S.VString{"Alice"}} : V.ComputedValue}
  xs = {Con{bob, Con{bob, Con{alice, Nil{}}}} : List<&2, V.ComputedValue>}
  actual = V.count_identity(bob, xs)
  Nat.is_eq(actual, 2n)
