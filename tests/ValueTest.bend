import Base
import ../src/Syntax.bend as S
import ../src/Value.bend as V

def check(same_bag: Bool, different_bag: Bool) -> Bool:
  match same_bag:
    case True{}:
      match different_bag:
        case True{}: False{}
        case False{}: True{}
    case False{}: False{}

def main() -> Bool:
  +bob = {V.CVScalar{S.VString{"Bob"}} : V.ComputedValue}
  +alice = {V.CVScalar{S.VString{"Alice"}} : V.ComputedValue}
  +left = {Con{bob, Con{bob, Con{alice, Nil{}}}} : List<&2, V.ComputedValue>}
  right = {Con{alice, Con{bob, Con{bob, Nil{}}}} : List<&2, V.ComputedValue>}
  short = {Con{alice, Con{bob, Nil{}}} : List<&2, V.ComputedValue>}
  same_bag = V.unordered_equivalent(left, right)
  different_bag = V.unordered_equivalent(left, short)
  check(same_bag, different_bag)
