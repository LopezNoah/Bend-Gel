import Base
import ../Cardinality.bend as C
import ../src/Syntax.bend as S
import ../src/Value.bend as V
import ../src/Store.bend as M

def movie() -> S.TypeName:
  {S.TypeName{"Movie"} : S.TypeName}

def title() -> S.Label:
  {S.Label{"title"} : S.Label}

def initial_store() -> M.Store:
  id = {S.ObjectId{1n} : S.ObjectId}
  value = {V.SVScalar{S.VString{"Transistors"}} : V.StoredValue}
  fields = {Con{V.SVField{title(), Con{value, Nil{}}}, Nil{}} : List<&2, V.StoredValue>}
  object = {M.StoredObject{id, movie(), M.Unlocked{}, fields} : M.StoredObject}
  {M.Store{Con{object, Nil{}}, 2n} : M.Store}

def is_one(values: List<&2, V.ComputedValue>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{head, tail}:
      match tail:
        case Nil{}: True{}
        case Con{other, rest}: False{}

def main() -> Bool:
  +store = initial_store()
  roots = M.root_values(movie(), store)
  projected = M.project_values(store, title(), roots)
  is_one(projected)
