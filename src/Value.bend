import Base
import ./Syntax.bend as S

type Visibility is Data:
  Visible{}
  Hidden{}

# Stored values retain link occurrences. SVRef carries the properties of this
# particular edge, rather than placing them on the referenced object.
type StoredValue is Data:
  SVScalar{value: S.ScalarValue}
  SVRef{target: S.ObjectId, link_properties: List<&2, StoredValue>}
  SVField{label: S.Label, values: List<&2, StoredValue>}

# Computed values are W and shape records use CVField. CVObject may therefore
# carry several occurrences of one object identity with different edge data.
type ComputedValue is Data:
  CVScalar{value: S.ScalarValue}
  CVObject{id: S.ObjectId, fields: List<&2, ComputedValue>}
  CVField{label: S.Label, visibility: Visibility, values: List<&2, ComputedValue>}

def bool_to_nat(value: Bool) -> Nat:
  match value:
    case True{}: 1n
    case False{}: 0n

def value_identity_equal(a: ComputedValue, b: ComputedValue) -> Bool:
  match a:
    case CVScalar{value}:
      match b:
        case CVScalar{other}: S.scalar_value_eq(value, other)
        case CVObject{id, fields}: False{}
        case CVField{label, visibility, values}: False{}
    case CVObject{id, fields}:
      match b:
        case CVScalar{value}: False{}
        case CVObject{other, other_fields}: S.object_id_eq(id, other)
        case CVField{label, visibility, values}: False{}
    case CVField{label, visibility, values}:
      match b:
        case CVScalar{value}: False{}
        case CVObject{id, fields}: False{}
        case CVField{other, other_visibility, other_values}: S.label_eq(label, other)

# Object equality in the v0 result-equivalence relation is identity equality;
# link provenance remains observable through projection before comparison.
def add_if(flag: Bool, n: Nat) -> Nat:
  match flag:
    case True{}: 1n+n
    case False{}: n

def value_length(xs: List<&2, ComputedValue>) -> Nat:
  match xs:
    case Nil{}: 0n
    case Con{head, tail}: 1n+value_length(tail)

def count_identity(+needle: ComputedValue, xs: List<&2, ComputedValue>) -> Nat:
  match xs:
    case Nil{}:
      0n
    case Con{head, tail}:
      hit = value_identity_equal(needle, head)
      count = count_identity(needle, tail)
      add_if(hit, count)

def all_counts_equal_from(remaining: List<&2, ComputedValue>, +left_all: List<&2, ComputedValue>, +right_all: List<&2, ComputedValue>) -> Bool:
  match remaining:
    case Nil{}:
      True{}
    case Con{+head, +tail}:
      left_count = count_identity(head, left_all)
      right_count = count_identity(head, right_all)
      counts_match = Nat.is_eq(left_count, right_count)
      rest_match = all_counts_equal_from(tail, left_all, right_all)
      Bool.and(counts_match, rest_match)

def all_counts_equal(+xs: List<&2, ComputedValue>, +ys: List<&2, ComputedValue>) -> Bool:
  all_counts_equal_from(xs, xs, ys)

def ordered_equal(xs: List<&2, ComputedValue>, ys: List<&2, ComputedValue>) -> Bool:
  match xs:
    case Nil{}:
      match ys:
        case Nil{}: True{}
        case Con{head, tail}: False{}
    case Con{head, tail}:
      match ys:
        case Nil{}: False{}
        case Con{other, others}:
          same_head = value_identity_equal(head, other)
          same_tail = ordered_equal(tail, others)
          Bool.and(same_head, same_tail)

# This is bag/multiset equivalence, not set equivalence: every identity's
# occurrence count must agree and the list lengths must agree.
def unordered_equivalent(+xs: List<&2, ComputedValue>, +ys: List<&2, ComputedValue>) -> Bool:
  same_length = Nat.is_eq(value_length(xs), value_length(ys))
  same_counts = all_counts_equal(xs, ys)
  Bool.and(same_length, same_counts)

def append_values(xs: List<&2, ComputedValue>, +ys: List<&2, ComputedValue>) -> List<&2, ComputedValue>:
  match xs:
    case Nil{}:
      ys
    case Con{head, tail}:
      Con{head, append_values(tail, ys)}

def append_stored_values(xs: List<&2, StoredValue>, +ys: List<&2, StoredValue>) -> List<&2, StoredValue>:
  match xs:
    case Nil{}:
      ys
    case Con{head, tail}:
      Con{head, append_stored_values(tail, ys)}

def append_if(flag: Bool, yes: List<&2, ComputedValue>, no: List<&2, ComputedValue>) -> List<&2, ComputedValue>:
  match flag:
    case True{}: append_values(yes, no)
    case False{}: no

def project_fields(+label: S.Label, fields: List<&2, ComputedValue>) -> List<&2, ComputedValue>:
  match fields:
    case Nil{}:
      Nil{}
    case Con{head, tail}:
      match head:
        case CVField{found, visibility, values}:
          rest = project_fields(label, tail)
          same = S.label_eq(label, found)
          append_if(same, values, rest)
        case CVScalar{value}:
          project_fields(label, tail)
        case CVObject{id, object_fields}:
          project_fields(label, tail)

def field_list_has_label(+label: S.Label, fields: List<&2, ComputedValue>) -> Bool:
  match fields:
    case Nil{}:
      False{}
    case Con{head, tail}:
      match head:
        case CVField{found, visibility, values}:
          same = S.label_eq(label, found)
          rest = field_list_has_label(label, tail)
          Bool.or(same, rest)
        case CVScalar{value}:
          field_list_has_label(label, tail)
        case CVObject{id, object_fields}:
          field_list_has_label(label, tail)

def hide_if_unshadowed(keep: Bool, label: S.Label, visibility: Visibility, values: List<&2, ComputedValue>) -> List<&2, ComputedValue>:
  match keep:
    case True{}: Nil{}
    case False{}: Con{CVField{label, Hidden{}, values}, Nil{}}

def hide_unshadowed(old: List<&2, ComputedValue>, +added: List<&2, ComputedValue>) -> List<&2, ComputedValue>:
  match old:
    case Nil{}:
      Nil{}
    case Con{head, tail}:
      match head:
        case CVField{+label, visibility, values}:
          rest = hide_unshadowed(tail, added)
          shadowed = field_list_has_label(label, added)
          current = hide_if_unshadowed(shadowed, label, visibility, values)
          append_values(current, rest)
        case CVScalar{value}:
          hide_unshadowed(tail, added)
        case CVObject{id, fields}:
          hide_unshadowed(tail, added)

def record_extend(old: List<&2, ComputedValue>, +added: List<&2, ComputedValue>) -> List<&2, ComputedValue>:
  retained = hide_unshadowed(old, added)
  append_values(retained, added)
