import Base
import ./Syntax.bend as S
import ./Value.bend as V
import ../Cardinality.bend as C

# Runtime value classification used by evaluator soundness checks.
type ValueType is Data:
  ValueMatches{}
  ValueMismatch{}

def scalar_value_matches_type(value: S.ScalarValue, typ: S.ScalarType) -> Bool:
  actual = S.scalar_type_of(value)
  S.scalar_type_eq(actual, typ)

def values_match_scalar(values: List<&2, V.ComputedValue>, scalar: S.ScalarType) -> Bool:
  match values:
    case Nil{}:
      True{}
    case Con{value, rest}:
      match value:
        case V.CVScalar{actual}:
          current = scalar_value_matches_type(actual, scalar)
          later = values_match_scalar(rest, scalar)
          Bool.and(current, later)
        case V.CVObject{id, fields}:
          False{}
        case V.CVField{label, visibility, fields}:
          False{}

def values_match_type(values: List<&2, V.ComputedValue>, typ: S.QueryType, card: C.Card) -> Bool:
  count_ok = C.accepts(card, V.value_length(values))
  match typ:
    case S.QScalar{scalar}:
      entries_ok = values_match_scalar(values, scalar)
      Bool.and(count_ok, entries_ok)
    case S.QObject{name, fields}:
      # Object values are typed by their stable object identity. Stored/object
      # field validation is checked separately by Store.well_formed in v0.
      objects_only = values_are_objects(values)
      Bool.and(count_ok, objects_only)

def values_are_objects(values: List<&2, V.ComputedValue>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value, rest}:
      match value:
        case V.CVScalar{scalar}: False{}
        case V.CVObject{id, fields}: values_are_objects(rest)
        case V.CVField{label, visibility, fields}: False{}
