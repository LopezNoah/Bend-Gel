import Base
import ../Cardinality.bend as C
import ../src/Syntax.bend as S
import ../src/Schema.bend as D
import ../src/Typecheck.bend as T

def empty_schema() -> D.Schema:
  {D.Schema{Nil{}} : D.Schema}

def root_schema() -> D.Schema:
  movie = {D.ObjectSchema{S.TypeName{"Movie"}, Nil{}} : D.ObjectSchema}
  {D.Schema{Con{movie, Nil{}}} : D.Schema}

def is_ok(result: T.Synth) -> Bool:
  match result:
    case T.SynthOK{typ, card}: True{}
    case T.SynthError{error}: False{}

def synth_card(result: T.Synth) -> C.Card:
  match result:
    case T.SynthOK{typ, card}:
      card
    case T.SynthError{error}:
      C.CEmpty{}

def type_root_is_many_regression() -> {
  synth_card(
    T.synth(
      root_schema(),
      Nil{},
      {S.ETypeRoot{S.TypeName{"Movie"}} : S.Expr}
    )
  ) == C.CMany{} : C.Card
}:
  {==}

def main() -> Bool:
  expression = {S.ELit{S.VInt{7n}} : S.Expr}
  result = T.synth(empty_schema(), Nil{}, expression)
  is_ok(result)