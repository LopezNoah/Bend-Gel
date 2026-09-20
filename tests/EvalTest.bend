import Base
import ../src/Syntax.bend as S
import ../src/Schema.bend as D
import ../src/Store.bend as M
import ../src/Eval.bend as E

def empty_schema() -> D.Schema:
  {D.Schema{Nil{}} : D.Schema}

def empty_store() -> M.Store:
  {M.Store{Nil{}, 1n} : M.Store}

def is_ok(outcome: E.EvalOutcome) -> Bool:
  match outcome:
    case E.EvalOK{result}: True{}
    case E.EvalError{error}: False{}

def main() -> Bool:
  query = {S.EUnion{S.ELit{S.VInt{1n}}, S.ELit{S.VInt{2n}}} : S.Expr}
  outcome = E.eval(empty_schema(), empty_store(), empty_store(), Nil{}, query)
  is_ok(outcome)
