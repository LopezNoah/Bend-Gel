import Base
import ./Syntax.bend as S
import ./EdgeQLSyntax.bend as E

type Subject is Data:
  NoSubject{}
  HasSubject{var: S.Var}

type NameBinding is Data:
  NameBinding{name: E.Name, var: S.Var}

type ElabError is Data:
  MissingSubject{}
  UnknownBuiltin{name: E.Name}
  UnsupportedSurfaceForm{}
  ElabStepLimit{}

type ElabResult is Data:
  Elaborated{value: S.Expr}
  ElabFailed{error: ElabError}

type ElabValue is Data:
  ExprValue{value: S.Expr, next_id: Nat}
  FieldsValue{fields: List<&2, S.Expr>, next_id: Nat}

type BinaryKind is Data:
  UnionKind{}
  EqualsKind{}
  AddKind{}
  CoalesceKind{}

type ElabContinuation is Data:
  ElabHalt{}
  PathContinuation{label: S.Label, next: ElabContinuation}
  BinaryLeftContinuation{kind: BinaryKind, right: E.SurfaceExpr, subject: Subject, bindings: List<&2, NameBinding>, next: ElabContinuation}
  BinaryRightContinuation{kind: BinaryKind, left: S.Expr, next: ElabContinuation}
  CallArgumentContinuation{name: E.Name, remaining: List<&2, E.SurfaceExpr>, collected: List<&2, S.Expr>, subject: Subject, bindings: List<&2, NameBinding>, next: ElabContinuation}
  WithBoundContinuation{name: E.Name, body: E.SurfaceExpr, bindings: List<&2, NameBinding>, next: ElabContinuation}
  WithBodyContinuation{bound: S.Expr, binder: S.Var, next: ElabContinuation}
  ForSourceContinuation{name: E.Name, body: E.SurfaceExpr, bindings: List<&2, NameBinding>, next: ElabContinuation}
  ForBodyContinuation{source: S.Expr, binder: S.Var, next: ElabContinuation}
  SelectResultContinuation{binder: S.Var, shape: List<&2, E.SurfaceExpr>, filter: E.SurfaceExpr, order: E.SurfaceExpr, bindings: List<&2, NameBinding>, next: ElabContinuation}
  SelectFilterContinuation{source: S.Expr, binder: S.Var, shape: List<&2, E.SurfaceExpr>, order: E.SurfaceExpr, bindings: List<&2, NameBinding>, next: ElabContinuation}
  SelectSourceContinuation{source: S.Expr, binder: S.Var, shape: List<&2, E.SurfaceExpr>, order: E.SurfaceExpr, bindings: List<&2, NameBinding>, next: ElabContinuation}
  SelectOrderContinuation{source: S.Expr, binder: S.Var, shape: List<&2, E.SurfaceExpr>, bindings: List<&2, NameBinding>, next: ElabContinuation}
  SelectShapeContinuation{source: S.Expr, binder: S.Var, next: ElabContinuation}
  InsertFieldsContinuation{object_type: E.Name, next: ElabContinuation}
  UpdateSourceContinuation{binder: S.Var, fields: List<&2, E.SurfaceExpr>, filter: E.SurfaceExpr, bindings: List<&2, NameBinding>, next: ElabContinuation}
  UpdateFilterContinuation{source: S.Expr, binder: S.Var, fields: List<&2, E.SurfaceExpr>, bindings: List<&2, NameBinding>, next: ElabContinuation}
  UpdateFieldsContinuation{source: S.Expr, binder: S.Var, next: ElabContinuation}
  ShapeComputedContinuation{label: S.Label, remaining: List<&2, E.SurfaceExpr>, subject: Subject, bindings: List<&2, NameBinding>, collected: List<&2, S.Expr>, next_id: Nat, next: ElabContinuation}
  ShapeNestedContinuation{label: S.Label, remaining: List<&2, E.SurfaceExpr>, outer_subject: Subject, bindings: List<&2, NameBinding>, collected: List<&2, S.Expr>, next_id: Nat, nested_binder: S.Var, next: ElabContinuation}

type ElabState is Data:
  EvalExpr{surface: E.SurfaceExpr, subject: Subject, bindings: List<&2, NameBinding>, next_id: Nat, continuation: ElabContinuation}
  EvalFields{elements: List<&2, E.SurfaceExpr>, subject: Subject, bindings: List<&2, NameBinding>, collected: List<&2, S.Expr>, next_id: Nat, continuation: ElabContinuation}
  ReturnExpr{value: S.Expr, next_id: Nat, continuation: ElabContinuation}
  ReturnFields{fields: List<&2, S.Expr>, next_id: Nat, continuation: ElabContinuation}
  ElabFailure{error: ElabError}

def name_text(name: E.Name) -> String:
  match name:
    case E.Name{text}: text

def name_eq(a: E.Name, b: E.Name) -> Bool:
  String.eq(name_text(a), name_text(b))

type LookupState is Data:
  LookupScan{name: E.Name, bindings: List<&2, NameBinding>}
  LookupCompare{name: E.Name, var: S.Var, rest: List<&2, NameBinding>, same: Bool}

def lookup_name_go(fuel: Nat, state: LookupState) -> Maybe<&2, S.Var>:
  match fuel:
    case 0n: None{}
    case 1n+remaining:
      match state:
        case LookupScan{+name, bindings}:
          match bindings:
            case Nil{}: None{}
            case Con{binding, rest}:
              match binding:
                case NameBinding{found, var}:
                  lookup_name_go(remaining, LookupCompare{name, var, rest, name_eq(name, found)})
        case LookupCompare{name, var, rest, +same}:
          match same:
            case True{}: Some{var}
            case False{}: lookup_name_go(remaining, LookupScan{name, rest})

def lookup_name(+name: E.Name, bindings: List<&2, NameBinding>) -> Maybe<&2, S.Var>:
  lookup_name_go(100000n, LookupScan{name, bindings})

def label_from_name(name: E.Name) -> S.Label:
  S.Label{name_text(name)}

def project_subject(subject: Subject, label: S.Label) -> S.Expr:
  match subject:
    case NoSubject{}: S.ETypeRoot{S.TypeName{"<missing-subject>"}}
    case HasSubject{var}: S.EProject{S.EVar{var}, label}

def var_from_name(name: E.Name) -> S.Var:
  S.Var{name_text(name)}

def prepend_binding(name: E.Name, var: S.Var, +bindings: List<&2, NameBinding>) -> List<&2, NameBinding>:
  Con{NameBinding{name, var}, bindings}

def fresh_var(next_id: Nat) -> S.Var:
  S.Var{"__subject" ++ Nat.show(next_id)}

def literal_value(literal: E.Literal) -> S.ScalarValue:
  match literal:
    case E.LInt{value}: S.VInt{value}
    case E.LBool{value}: S.VBool{value}
    case E.LString{value}: S.VString{value}

def binary_expression(kind: BinaryKind, left: S.Expr, right: S.Expr) -> S.Expr:
  match kind:
    case UnionKind{}: S.EUnion{left, right}
    case EqualsKind{}: S.ECall{S.BEq{}, Con{left, Con{right, Nil{}}}}
    case AddKind{}: S.ECall{S.BAdd{}, Con{left, Con{right, Nil{}}}}
    case CoalesceKind{}: S.ECall{S.BCoalesce{}, Con{left, Con{right, Nil{}}}}

def nested_source(subject: Subject, label: S.Label) -> S.Expr:
  project_subject(subject, label)

def shape_field_value(+name: E.Name, subject: Subject) -> S.Expr:
  S.EField{label_from_name(name), project_subject(subject, label_from_name(name))}

def computed_field(label: S.Label, value: S.Expr) -> S.Expr:
  S.EField{label, value}

def select_shape_fields_state(+source: S.Expr, +binder: S.Var, fields: List<&2, S.Expr>, next_id: Nat, next: ElabContinuation) -> ElabState:
  ReturnExpr{S.EFor{source, binder, S.EShape{source, binder, fields}}, next_id, next}

def nested_shape_field(+label: S.Label, outer_subject: Subject, nested_binder: S.Var, fields: List<&2, S.Expr>) -> S.Expr:
  S.EField{label, S.EShape{nested_source(outer_subject, label), nested_binder, fields}}

def select_filter_state(+source: S.Expr, +binder: S.Var, +condition: S.Expr, shape: List<&2, E.SurfaceExpr>, order: E.SurfaceExpr, bindings: List<&2, NameBinding>, next_id: Nat, next: ElabContinuation) -> ElabState:
  ReturnExpr{S.EFilter{source, binder, condition}, next_id, SelectSourceContinuation{S.EFilter{source, binder, condition}, binder, shape, order, bindings, next}}

def update_filter_state(+source: S.Expr, +binder: S.Var, +condition: S.Expr, fields: List<&2, E.SurfaceExpr>, bindings: List<&2, NameBinding>, next_id: Nat, next: ElabContinuation) -> ElabState:
  EvalFields{fields, HasSubject{binder}, bindings, Nil{}, next_id, UpdateFieldsContinuation{S.EFilter{source, binder, condition}, binder, next}}

def builtin_for_text(text: String) -> Maybe<&2, S.Builtin>:
  match text:
    case "count": Some{S.BCount{}}
    case "any": Some{S.BAny{}}
    case "eq": Some{S.BEq{}}
    case "add": Some{S.BAdd{}}
    case "concat": Some{S.BConcat{}}
    case "coalesce": Some{S.BCoalesce{}}
    case _: None{}

def builtin_for_name(name: E.Name) -> Maybe<&2, S.Builtin>:
  builtin_for_text(name_text(name))

def resolve_name_state(result: Maybe<&2, S.Var>, name: E.Name, next_id: Nat, continuation: ElabContinuation) -> ElabState:
  match result:
    case None{}: ReturnExpr{S.ETypeRoot{S.TypeName{name_text(name)}}, next_id, continuation}
    case Some{var}: ReturnExpr{S.EVar{var}, next_id, continuation}

def builtin_noarg_state(result: Maybe<&2, S.Builtin>, name: E.Name, next_id: Nat, continuation: ElabContinuation) -> ElabState:
  match result:
    case None{}: ElabFailure{UnknownBuiltin{name}}
    case Some{builtin}: ReturnExpr{S.ECall{builtin, Nil{}}, next_id, continuation}

def call_finished_state(result: Maybe<&2, S.Builtin>, name: E.Name, args: List<&2, S.Expr>, next_id: Nat, continuation: ElabContinuation) -> ElabState:
  match result:
    case None{}: ElabFailure{UnknownBuiltin{name}}
    case Some{builtin}: ReturnExpr{S.ECall{builtin, List.reverse(&2, S.Expr, args)}, next_id, continuation}

def empty_field_list() -> List<&2, S.Expr>:
  Nil{}

def elaborate_go(fuel: Nat, state: ElabState) -> ElabResult:
  match fuel:
    case 0n: ElabFailed{ElabStepLimit{}}
    case 1n+remaining:
      match state:
        case EvalExpr{surface, +subject, +bindings, +next_id, continuation}:
          match surface:
            case E.SLiteral{value}: elaborate_go(remaining, ReturnExpr{S.ELit{literal_value(value)}, next_id, continuation})
            case E.SName{+name}:
              elaborate_go(remaining, resolve_name_state(lookup_name(name, bindings), name, next_id, continuation))
            case E.SVariable{name}: elaborate_go(remaining, ReturnExpr{S.EVar{var_from_name(name)}, next_id, continuation})
            case E.SPartialPath{name}:
              match subject:
                case NoSubject{}: ElabFailed{MissingSubject{}}
                case HasSubject{var}: elaborate_go(remaining, ReturnExpr{S.EProject{S.EVar{var}, label_from_name(name)}, next_id, continuation})
            case E.SPath{source, E.Name{text}}: elaborate_go(remaining, EvalExpr{source, subject, bindings, next_id, PathContinuation{S.Label{text}, continuation}})
            case E.SCall{+name, args}:
              match args:
                case Nil{}:
                  elaborate_go(remaining, builtin_noarg_state(builtin_for_name(name), name, next_id, continuation))
                case Con{first, rest}:
                  elaborate_go(remaining, EvalExpr{first, subject, bindings, next_id, CallArgumentContinuation{name, rest, Nil{}, subject, bindings, continuation}})
            case E.SUnion{left, right}: elaborate_go(remaining, EvalExpr{left, subject, bindings, next_id, BinaryLeftContinuation{UnionKind{}, right, subject, bindings, continuation}})
            case E.SEq{left, right}: elaborate_go(remaining, EvalExpr{left, subject, bindings, next_id, BinaryLeftContinuation{EqualsKind{}, right, subject, bindings, continuation}})
            case E.SAdd{left, right}: elaborate_go(remaining, EvalExpr{left, subject, bindings, next_id, BinaryLeftContinuation{AddKind{}, right, subject, bindings, continuation}})
            case E.SCoalesce{left, right}: elaborate_go(remaining, EvalExpr{left, subject, bindings, next_id, BinaryLeftContinuation{CoalesceKind{}, right, subject, bindings, continuation}})
            case E.SWith{+name, bound, body}: elaborate_go(remaining, EvalExpr{bound, subject, bindings, next_id, WithBoundContinuation{name, body, bindings, continuation}})
            case E.SFor{+name, source, body}: elaborate_go(remaining, EvalExpr{source, subject, bindings, next_id, ForSourceContinuation{name, body, bindings, continuation}})
            case E.SSelect{result, shape, filter, order}:
              binder = fresh_var(next_id)
              elaborate_go(remaining, EvalExpr{result, subject, bindings, 1n+next_id, SelectResultContinuation{binder, shape, filter, order, bindings, continuation}})
            case E.SInsert{object_type, fields}:
              elaborate_go(remaining, EvalFields{fields, NoSubject{}, bindings, Nil{}, next_id, InsertFieldsContinuation{object_type, continuation}})
            case E.SUpdate{source, filter, fields}:
              binder = fresh_var(next_id)
              elaborate_go(remaining, EvalExpr{source, subject, bindings, 1n+next_id, UpdateSourceContinuation{binder, fields, filter, bindings, continuation}})
            case _: elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
        case EvalFields{elements, +subject, +bindings, collected, +next_id, continuation}:
          match elements:
            case Nil{}:
              elaborate_go(remaining, ReturnFields{List.reverse(&2, S.Expr, collected), next_id, continuation})
            case Con{element, rest}:
              match element:
                case E.SShapeField{name}:
                  field = shape_field_value(name, subject)
                  elaborate_go(remaining, EvalFields{rest, subject, bindings, Con{field, collected}, next_id, continuation})
                case E.SShapeComputed{name, value}:
                  elaborate_go(remaining, EvalExpr{value, subject, bindings, next_id, ShapeComputedContinuation{label_from_name(name), rest, subject, bindings, collected, next_id, continuation}})
                case E.SShapeNested{+name, fields}:
                  elaborate_go(remaining, EvalFields{fields, HasSubject{fresh_var(next_id)}, bindings, Nil{}, 1n+next_id, ShapeNestedContinuation{label_from_name(name), rest, subject, bindings, collected, next_id, fresh_var(next_id), continuation}})
                case _: elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
        case ReturnExpr{+value, next_id, continuation}:
          match continuation:
            case ElabHalt{}: Elaborated{value}
            case PathContinuation{label, next}:
              elaborate_go(remaining, ReturnExpr{S.EProject{value, label}, next_id, next})
            case BinaryLeftContinuation{kind, right, subject, bindings, next}:
              elaborate_go(remaining, EvalExpr{right, subject, bindings, next_id, BinaryRightContinuation{kind, value, next}})
            case BinaryRightContinuation{kind, left, next}:
              elaborate_go(remaining, ReturnExpr{binary_expression(kind, left, value), next_id, next})
            case CallArgumentContinuation{+name, Nil{}, collected, subject, bindings, next}:
              elaborate_go(remaining, call_finished_state(builtin_for_name(name), name, Con{value, collected}, next_id, next))
            case CallArgumentContinuation{name, Con{first, rest}, +collected, +subject, +bindings, next}:
              elaborate_go(remaining, EvalExpr{first, subject, bindings, next_id, CallArgumentContinuation{name, rest, Con{value, collected}, subject, bindings, next}})
            case WithBoundContinuation{+name, body, bindings, next}:
              elaborate_go(remaining, EvalExpr{body, NoSubject{}, prepend_binding(name, var_from_name(name), bindings), next_id, WithBodyContinuation{value, var_from_name(name), next}})
            case WithBodyContinuation{bound, binder, next}:
              elaborate_go(remaining, ReturnExpr{S.EWith{bound, binder, value}, next_id, next})
            case ForSourceContinuation{+name, body, bindings, next}:
              elaborate_go(remaining, EvalExpr{body, NoSubject{}, prepend_binding(name, var_from_name(name), bindings), next_id, ForBodyContinuation{value, var_from_name(name), next}})
            case ForBodyContinuation{source, binder, next}:
              elaborate_go(remaining, ReturnExpr{S.EFor{source, binder, value}, next_id, next})
            case SelectResultContinuation{+binder, shape, E.SNoFilter{}, order, +bindings, next}:
              elaborate_go(remaining, ReturnExpr{value, next_id, SelectSourceContinuation{value, binder, shape, order, bindings, next}})
            case SelectResultContinuation{+binder, shape, E.SFilter{condition}, order, +bindings, next}:
              elaborate_go(remaining, EvalExpr{condition, HasSubject{binder}, bindings, next_id, SelectFilterContinuation{value, binder, shape, order, bindings, next}})
            case SelectResultContinuation{binder, shape, filter, order, bindings, next}:
              elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
            case SelectFilterContinuation{source, +binder, shape, order, bindings, next}:
              elaborate_go(remaining, select_filter_state(source, binder, value, shape, order, bindings, next_id, next))
            case SelectSourceContinuation{source, +binder, shape, E.SOrder{key, direction}, +bindings, next}:
              elaborate_go(remaining, EvalExpr{key, HasSubject{binder}, bindings, next_id, SelectOrderContinuation{source, binder, shape, bindings, next}})
            case SelectSourceContinuation{source, binder, Nil{}, E.SNoOrder{}, bindings, next}:
              elaborate_go(remaining, ReturnExpr{source, next_id, next})
            case SelectSourceContinuation{source, binder, Con{head, tail}, E.SNoOrder{}, bindings, next}:
              elaborate_go(remaining, EvalFields{Con{head, tail}, HasSubject{binder}, bindings, Nil{}, next_id, SelectShapeContinuation{source, binder, next}})
            case SelectSourceContinuation{source, binder, shape, order, bindings, next}:
              elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
            case SelectOrderContinuation{source, binder, Nil{}, bindings, next}:
              elaborate_go(remaining, ReturnExpr{S.EOrderBy{source, binder, value}, next_id, next})
            case SelectOrderContinuation{+source, +binder, Con{head, tail}, bindings, next}:
              elaborate_go(remaining, EvalFields{Con{head, tail}, HasSubject{binder}, bindings, Nil{}, next_id, SelectShapeContinuation{S.EOrderBy{source, binder, value}, binder, next}})
            case SelectShapeContinuation{source, binder, next}:
              elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
            case UpdateSourceContinuation{+binder, fields, E.SNoFilter{}, bindings, next}:
              elaborate_go(remaining, EvalFields{fields, HasSubject{binder}, bindings, Nil{}, next_id, UpdateFieldsContinuation{value, binder, next}})
            case UpdateSourceContinuation{+binder, fields, E.SFilter{condition}, +bindings, next}:
              elaborate_go(remaining, EvalExpr{condition, HasSubject{binder}, bindings, next_id, UpdateFilterContinuation{value, binder, fields, bindings, next}})
            case UpdateSourceContinuation{binder, fields, filter, bindings, next}:
              elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
            case UpdateFilterContinuation{source, binder, fields, bindings, next}:
              elaborate_go(remaining, update_filter_state(source, binder, value, fields, bindings, next_id, next))
            case UpdateFieldsContinuation{source, binder, next}:
              elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
            case ShapeComputedContinuation{label, rest_fields, subject, bindings, collected, next_id, next}:
              elaborate_go(remaining, EvalFields{rest_fields, subject, bindings, Con{computed_field(label, value), collected}, next_id, next})
            case _: elaborate_go(remaining, ElabFailure{UnsupportedSurfaceForm{}})
        case ReturnFields{fields, next_id, continuation}:
          match continuation:
            case SelectShapeContinuation{source, binder, next}:
              elaborate_go(remaining, select_shape_fields_state(source, binder, fields, next_id, next))
            case InsertFieldsContinuation{object_type, next}:
              elaborate_go(remaining, ReturnExpr{S.EInsert{S.TypeName{name_text(object_type)}, fields}, next_id, next})
            case UpdateFieldsContinuation{source, binder, next}:
              elaborate_go(remaining, ReturnExpr{S.EUpdate{source, binder, fields}, next_id, next})
            case ShapeNestedContinuation{label, rest_fields, outer_subject, bindings, collected, next_id, nested_binder, next}:
              elaborate_go(remaining, EvalFields{rest_fields, outer_subject, bindings, Con{nested_shape_field(label, outer_subject, nested_binder, fields), collected}, next_id, next})
            case _: ElabFailed{ElabStepLimit{}}
        case ElabFailure{error}: ElabFailed{error}

def elaborate(surface: E.SurfaceExpr) -> ElabResult:
  elaborate_go(100000n, EvalExpr{surface, NoSubject{}, Nil{}, 0n, ElabHalt{}})
