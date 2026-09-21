import Base
import ../src/Syntax.bend as S
import ../src/Schema.bend as D
import ../src/Store.bend as M
import ../src/Eval.bend as E
import ../src/Value.bend as V

def empty_schema() -> D.Schema:
  {D.Schema{Nil{}} : D.Schema}

def empty_store() -> M.Store:
  {M.Store{Nil{}, 1n} : M.Store}

def is_ok(outcome: E.EvalOutcome) -> Bool:
  match outcome:
    case E.EvalOK{result}: True{}
    case E.EvalError{error}: False{}

def is_single_one(outcome: E.EvalOutcome) -> Bool:
  match outcome:
    case E.EvalError{error}: False{}
    case E.EvalOK{E.EvalResult{values, store}}:
      match values:
        case Con{V.CVScalar{S.VInt{1n}}, Nil{}}: True{}
        case _: False{}

def main() -> Bool:
  source = {S.EUnion{S.ELit{S.VInt{1n}}, S.ELit{S.VInt{2n}}} : S.Expr}
  predicate = {S.ECall{S.BEq{}, Con{S.EVar{S.Var{"value"}}, Con{S.ELit{S.VInt{1n}}, Nil{}}}} : S.Expr}
  query = {S.EFilter{source, S.Var{"value"}, predicate} : S.Expr}
  outcome = E.eval(empty_schema(), empty_store(), empty_store(), Nil{}, query)
  is_single_one(outcome)
