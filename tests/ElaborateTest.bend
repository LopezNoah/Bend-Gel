import Base
import ../src/Syntax.bend as S
import ../src/EdgeQLSyntax.bend as E
import ../src/Elaborate.bend as L

def is_rejected(result: L.ElabResult) -> Bool:
  match result:
    case L.ElabFailed{L.InvalidCoreExpr{}}: True{}
    case _: False{}

def is_valid_success(result: L.ElabResult) -> Bool:
  match result:
    case L.Elaborated{value}: S.valid_expr(value)
    case L.ElabFailed{error}: False{}

def main() -> Bool:
  literal = {S.ELit{S.VInt{1n}} : S.Expr}
  field = {S.EField{S.Label{"title"}, literal} : S.Expr}
  valid_shape = {S.EShape{S.ETypeRoot{S.TypeName{"Movie"}}, S.Var{"m"}, Con{field, Nil{}}} : S.Expr}
  invalid_call = {S.ECall{S.BCount{}, Con{S.EField{S.Label{"title"}, S.ELit{S.VInt{1n}}}, Nil{}}} : S.Expr}
  surface = {E.SInsert{E.Name{"Movie"}, Con{E.SShapeComputed{E.Name{"title"}, E.SLiteral{E.LInt{1n}}}, Nil{}}} : E.SurfaceExpr}
  Bool.and(S.valid_expr(valid_shape),
    Bool.and(Bool.not(S.valid_expr({S.ECall{S.BCount{}, Con{S.EField{S.Label{"title"}, S.ELit{S.VInt{1n}}}, Nil{}}} : S.Expr})),
      Bool.and(is_rejected(L.check_core_result(L.Elaborated{invalid_call})),
        is_valid_success(L.elaborate(surface)))))
