import Base
import ../src/Syntax.bend as S
import ../src/Schema.bend as D
import ../src/Typecheck.bend as T

def empty_schema() -> D.Schema:
  {D.Schema{Nil{}} : D.Schema}

def is_ok(result: T.Synth) -> Bool:
  match result:
    case T.SynthOK{typ, card}: True{}
    case T.SynthError{error}: False{}

def main() -> Bool:
  expression = {S.ELit{S.VInt{7n}} : S.Expr}
  result = T.synth(empty_schema(), Nil{}, expression)
  is_ok(result)
