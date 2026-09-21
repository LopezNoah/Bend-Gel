import Base

type Name is Data:
  Name{text: String}

type Literal is Data:
  LInt{value: Nat}
  LBool{value: Bool}
  LString{value: String}

type OrderDirection is Data:
  Asc{}
  Desc{}

# This is the grammar-facing AST.  It retains partial paths and implicit
# subjects until Elaborate.bend resolves them into the core calculus.
type SurfaceExpr is Data:
  SLiteral{value: Literal}
  SName{name: Name}
  SVariable{name: Name}
  SPartialPath{name: Name}
  SPath{source: SurfaceExpr, name: Name}
  SCall{name: Name, args: List<&2, SurfaceExpr>}
  SUnion{left: SurfaceExpr, right: SurfaceExpr}
  SEq{left: SurfaceExpr, right: SurfaceExpr}
  SAdd{left: SurfaceExpr, right: SurfaceExpr}
  SCoalesce{left: SurfaceExpr, right: SurfaceExpr}
  SNoFilter{}
  SFilter{value: SurfaceExpr}
  SNoOrder{}
  SOrder{key: SurfaceExpr, direction: OrderDirection}
  SShapeField{name: Name}
  SShapeComputed{name: Name, value: SurfaceExpr}
  SShapeNested{name: Name, fields: List<&2, SurfaceExpr>}
  SSelect{result: SurfaceExpr, shape: List<&2, SurfaceExpr>, filter: SurfaceExpr, order: SurfaceExpr}
  SWith{name: Name, bound: SurfaceExpr, body: SurfaceExpr}
  SFor{name: Name, source: SurfaceExpr, body: SurfaceExpr}
  SInsert{object_type: Name, fields: List<&2, SurfaceExpr>}
  SUpdate{source: SurfaceExpr, filter: SurfaceExpr, fields: List<&2, SurfaceExpr>}

type MaybeSurfaceExpr is Data:
  NoExpr{}
  SomeExpr{value: SurfaceExpr}

type MaybeOrder is Data:
  NoOrder{}
  SomeOrder{key: SurfaceExpr, direction: OrderDirection}

# Compatibility vocabulary for callers that want to name shape entries
# independently.  The parser stores the same entries as SurfaceExpr nodes so
# the recursive type is declared in one place, as required by Bend.
type ShapeElement is Data:
  ShapeField{name: Name}
  ShapeComputed{name: Name, value: SurfaceExpr}
  ShapeNested{name: Name, fields: List<&2, ShapeElement>}
