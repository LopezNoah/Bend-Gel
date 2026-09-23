import Base
import ../Cardinality.bend as C

# Names are distinct data types so a label cannot be accidentally supplied
# where an object type, binding variable, or object identity is required.
type TypeName is Data:
  TypeName{text: String}

type Label is Data:
  Label{text: String}

type Var is Data:
  Var{text: String}

type ObjectId is Data:
  ObjectId{serial: Nat}

type ScalarType is Data:
  TInt{}
  TBool{}
  TString{}

type ScalarValue is Data:
  VInt{value: Nat}
  VBool{value: Bool}
  VString{value: String}

# Stored types are the paper's T. Link properties are scalar by construction.
type StoredType is Data:
  SScalar{scalar: ScalarType}
  SLink{target: TypeName, link_properties: List<&2, StoredType>}
  SField{label: Label, typ: StoredType, card: C.Card}

# Computed types are the paper's tau. Shapes can carry recursively computed
# fields, which explains why this is separate from StoredType.
type QueryType is Data:
  QScalar{scalar: ScalarType}
  QObject{name: TypeName, fields: List<&2, StoredType>}

type Builtin is Data:
  BCount{}
  BAny{}
  BEq{}
  BAdd{}
  BConcat{}
  BCoalesce{}

# This is the v0 core AST. IfStrict and Update are the unlifted forms from the
# paper; source-level if/update are elaborated by the parser into For forms.
type Expr is Data:
  EVar{var: Var}
  ELit{value: ScalarValue}
  EEmpty{typ: QueryType}
  EUnion{left: Expr, right: Expr}
  ETypeRoot{name: TypeName}
  EProject{source: Expr, label: Label}
  EBacklink{source: Expr, label: Label, owner: TypeName}
  EField{label: Label, value: Expr}
  EShape{source: Expr, binder: Var, fields: List<&2, Expr>}
  ECall{builtin: Builtin, args: List<&2, Expr>}
  EIfStrict{condition: Expr, when_true: Expr, when_false: Expr}
  EWith{bound: Expr, binder: Var, body: Expr}
  EFor{source: Expr, binder: Var, body: Expr}
  EFilter{source: Expr, binder: Var, condition: Expr}
  EOrderBy{source: Expr, binder: Var, key: Expr}
  EInsert{object_type: TypeName, fields: List<&2, Expr>}
  EUpdate{source: Expr, binder: Var, fields: List<&2, Expr>}

# EField is a field-list entry, not an expression in its own right. The
# structural boundary admits it only in the field slots of shapes and
# mutations, and checks every expression nested inside those entries.
# This predicate does not claim that names resolve or that the term types.
# The worklist uses the same 100000-step bound as elaboration: exhausting it
# rejects the expression rather than accepting a partially checked tree.
type ValidNode is Data:
  CheckExpr{expr: Expr}
  CheckField{expr: Expr}

def queue_exprs(exprs: List<&2, Expr>, pending: List<&2, ValidNode>) -> List<&2, ValidNode>:
  match exprs:
    case Nil{}: pending
    case Con{expr, rest}: Con{CheckExpr{expr}, queue_exprs(rest, pending)}

def queue_fields(fields: List<&2, Expr>, pending: List<&2, ValidNode>) -> List<&2, ValidNode>:
  match fields:
    case Nil{}: pending
    case Con{field, rest}: Con{CheckField{field}, queue_fields(rest, pending)}

def valid_nodes(fuel: Nat, pending: List<&2, ValidNode>) -> Bool:
  match fuel:
    case 0n: False{}
    case 1n+remaining:
      match pending:
        case Nil{}: True{}
        case Con{node, rest}:
          match node:
            case CheckField{expr}:
              match expr:
                case EField{label, value}: valid_nodes(remaining, Con{CheckExpr{value}, rest})
                case _: False{}
            case CheckExpr{expr}:
              match expr:
                case EVar{var}: valid_nodes(remaining, rest)
                case ELit{value}: valid_nodes(remaining, rest)
                case EEmpty{typ}: valid_nodes(remaining, rest)
                case EUnion{left, right}: valid_nodes(remaining, Con{CheckExpr{left}, Con{CheckExpr{right}, rest}})
                case ETypeRoot{name}: valid_nodes(remaining, rest)
                case EProject{source, label}: valid_nodes(remaining, Con{CheckExpr{source}, rest})
                case EBacklink{source, label, owner}: valid_nodes(remaining, Con{CheckExpr{source}, rest})
                case EField{label, value}: False{}
                case EShape{source, binder, fields}: valid_nodes(remaining, Con{CheckExpr{source}, queue_fields(fields, rest)})
                case ECall{builtin, args}: valid_nodes(remaining, queue_exprs(args, rest))
                case EIfStrict{condition, when_true, when_false}:
                  valid_nodes(remaining, Con{CheckExpr{condition}, Con{CheckExpr{when_true}, Con{CheckExpr{when_false}, rest}}})
                case EWith{bound, binder, body}: valid_nodes(remaining, Con{CheckExpr{bound}, Con{CheckExpr{body}, rest}})
                case EFor{source, binder, body}: valid_nodes(remaining, Con{CheckExpr{source}, Con{CheckExpr{body}, rest}})
                case EFilter{source, binder, condition}: valid_nodes(remaining, Con{CheckExpr{source}, Con{CheckExpr{condition}, rest}})
                case EOrderBy{source, binder, key}: valid_nodes(remaining, Con{CheckExpr{source}, Con{CheckExpr{key}, rest}})
                case EInsert{object_type, fields}: valid_nodes(remaining, queue_fields(fields, rest))
                case EUpdate{source, binder, fields}: valid_nodes(remaining, Con{CheckExpr{source}, queue_fields(fields, rest)})

def valid_expr(expr: Expr) -> Bool:
  valid_nodes(100000n, Con{CheckExpr{expr}, Nil{}})

def type_name_eq(a: TypeName, b: TypeName) -> Bool:
  match a:
    case TypeName{+text}:
      match b:
        case TypeName{other}:
          String.eq(text, other)

def label_eq(a: Label, b: Label) -> Bool:
  match a:
    case Label{+text}:
      match b:
        case Label{other}:
          String.eq(text, other)

def var_eq(a: Var, b: Var) -> Bool:
  match a:
    case Var{+text}:
      match b:
        case Var{other}:
          String.eq(text, other)

def object_id_eq(a: ObjectId, b: ObjectId) -> Bool:
  match a:
    case ObjectId{serial}:
      match b:
        case ObjectId{other}:
          Nat.is_eq(serial, other)

def scalar_type_eq(a: ScalarType, b: ScalarType) -> Bool:
  match a:
    case TInt{}:
      match b:
        case TInt{}: True{}
        case _: False{}
    case TBool{}:
      match b:
        case TBool{}: True{}
        case _: False{}
    case TString{}:
      match b:
        case TString{}: True{}
        case _: False{}

def scalar_type_of(value: ScalarValue) -> ScalarType:
  match value:
    case VInt{value}:
      TInt{}
    case VBool{value}:
      TBool{}
    case VString{value}:
      TString{}

def bool_eq(a: Bool, b: Bool) -> Bool:
  match a:
    case True{}:
      match b:
        case True{}: True{}
        case False{}: False{}
    case False{}:
      match b:
        case True{}: False{}
        case False{}: True{}

def scalar_value_eq(a: ScalarValue, b: ScalarValue) -> Bool:
  match a:
    case VInt{value}:
      match b:
        case VInt{other}: Nat.is_eq(value, other)
        case VBool{other}: False{}
        case VString{other}: False{}
    case VBool{value}:
      match b:
        case VInt{other}: False{}
        case VBool{other}: bool_eq(value, other)
        case VString{other}: False{}
    case VString{value}:
      match b:
        case VInt{other}: False{}
        case VBool{other}: False{}
        case VString{other}: String.eq(value, other)
