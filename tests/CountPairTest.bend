import Base
import ../src/Syntax.bend as S
import ../src/Value.bend as V

def main() -> Bool:
  +bob = {V.CVScalar{S.VString{"Bob"}} : V.ComputedValue}
  +alice = {V.CVScalar{S.VString{"Alice"}} : V.ComputedValue}
  left = {Con{bob, Con{bob, Con{alice, Nil{}}}} : List<&2, V.ComputedValue>}
  right = {Con{alice, Con{bob, Con{bob, Nil{}}}} : List<&2, V.ComputedValue>}
  l = V.count_identity(bob, left)
  r = V.count_identity(bob, right)
  Nat.is_eq(l, r)
