import Base
import ./Syntax.bend as S

type ObjectSchema is Data:
  ObjectSchema{name: S.TypeName, fields: List<&2, S.StoredType>}

type Schema is Data:
  Schema{objects: List<&2, ObjectSchema>}

type SchemaError is Data:
  DuplicateType{type_name: S.TypeName}
  DuplicateLabel{type_name: S.TypeName, label: S.Label}
  UnknownLinkTarget{type_name: S.TypeName, label: S.Label, target: S.TypeName}
  NonScalarLinkProperty{type_name: S.TypeName, label: S.Label}

def object_name_eq(needle: S.TypeName, object: ObjectSchema) -> Bool:
  match object:
    case ObjectSchema{name, +fields}:
      S.type_name_eq(needle, name)

def schema_has_name(+needle: S.TypeName, objects: List<&2, ObjectSchema>) -> Bool:
  match objects:
    case Nil{}:
      False{}
    case Con{+object, rest}:
      found = object_name_eq(needle, object)
      later = schema_has_name(needle, rest)
      Bool.or(found, later)

def count_if(flag: Bool, rest: Nat) -> Nat:
  match flag:
    case True{}: 1n+rest
    case False{}: rest

def count_object_name(+needle: S.TypeName, objects: List<&2, ObjectSchema>) -> Nat:
  match objects:
    case Nil{}:
      0n
    case Con{object, rest}:
      found = object_name_eq(needle, object)
      later = count_object_name(needle, rest)
      count_if(found, later)

def first_field(fields: List<&2, S.StoredType>) -> Maybe<&2, S.StoredType>:
  match fields:
    case Nil{}: None{}
    case Con{head, tail}: Some{head}

def prepend_field_if(matches: Bool, field: S.StoredType, rest: List<&2, S.StoredType>) -> List<&2, S.StoredType>:
  match matches:
    case True{}: Con{field, rest}
    case False{}: rest

def matching_fields(+label: S.Label, fields: List<&2, S.StoredType>) -> List<&2, S.StoredType>:
  match fields:
    case Nil{}:
      Nil{}
    case Con{field, rest}:
      match field:
        case S.SField{+found, typ, card}:
          more = matching_fields(label, rest)
          same = S.label_eq(label, found)
          current = {S.SField{found, typ, card} : S.StoredType}
          prepend_field_if(same, current, more)
        case S.SScalar{scalar}:
          matching_fields(label, rest)
        case S.SLink{target, link_properties}:
          matching_fields(label, rest)

def prepend_object_if(matches: Bool, object: ObjectSchema, rest: List<&2, ObjectSchema>) -> List<&2, ObjectSchema>:
  match matches:
    case True{}: Con{object, rest}
    case False{}: rest

def matching_objects(+name: S.TypeName, objects: List<&2, ObjectSchema>) -> List<&2, ObjectSchema>:
  match objects:
    case Nil{}:
      Nil{}
    case Con{+object, rest}:
      later = matching_objects(name, rest)
      same = object_name_eq(name, object)
      prepend_object_if(same, object, later)

def first_object_fields(objects: List<&2, ObjectSchema>) -> List<&2, S.StoredType>:
  match objects:
    case Nil{}:
      Nil{}
    case Con{object, rest}:
      match object:
        case ObjectSchema{name, fields}:
          fields

def fields_for_name(name: S.TypeName, objects: List<&2, ObjectSchema>) -> List<&2, S.StoredType>:
  matches = matching_objects(name, objects)
  first_object_fields(matches)

def lookup_field(schema: Schema, name: S.TypeName, label: S.Label) -> Maybe<&2, S.StoredType>:
  match schema:
    case Schema{objects}:
      fields = fields_for_name(name, objects)
      matches = matching_fields(label, fields)
      first_field(matches)

def scalar_link_properties(props: List<&2, S.StoredType>) -> Bool:
  match props:
    case Nil{}:
      True{}
    case Con{field, rest}:
      match field:
        case S.SField{label, typ, card}:
          match typ:
            case S.SScalar{scalar}:
              scalar_link_properties(rest)
            case S.SLink{target, link_properties}:
              False{}
            case S.SField{inner_label, inner_type, inner_card}:
              False{}
        case S.SScalar{scalar}:
          False{}
        case S.SLink{target, link_properties}:
          False{}

def field_labels_unique(+fields: List<&2, S.StoredType>) -> Bool:
  match fields:
    case Nil{}:
      True{}
    case Con{+field, +rest}:
      match field:
        case S.SField{+label, typ, card}:
          current_field = {S.SField{label, typ, card} : S.StoredType}
          current = {Con{current_field, rest} : List<&2, S.StoredType>}
          copies = matching_fields(label, current)
          exactly_one = Nat.is_eq(List.length(&2, S.StoredType, copies), 1n)
          later = field_labels_unique(rest)
          Bool.and(exactly_one, later)
        case S.SScalar{scalar}:
          False{}
        case S.SLink{target, link_properties}:
          False{}

def all_fields_targets_exist(fields: List<&2, S.StoredType>, +objects: List<&2, ObjectSchema>) -> Bool:
  match fields:
    case Nil{}:
      True{}
    case Con{field, rest}:
      match field:
        case S.SField{label, typ, card}:
          match typ:
            case S.SScalar{scalar}:
              all_fields_targets_exist(rest, objects)
            case S.SLink{target, link_properties}:
              target_exists = schema_has_name(target, objects)
              props_ok = scalar_link_properties(link_properties)
              rest_ok = all_fields_targets_exist(rest, objects)
              Bool.and(target_exists, Bool.and(props_ok, rest_ok))
            case S.SField{inner_label, inner_type, inner_card}:
              False{}
        case S.SScalar{scalar}:
          False{}
        case S.SLink{target, link_properties}:
          False{}

def object_is_valid(object: ObjectSchema, +all_objects: List<&2, ObjectSchema>) -> Bool:
  match object:
    case ObjectSchema{name, +fields}:
      one_name = Nat.is_eq(count_object_name(name, all_objects), 1n)
      labels_ok = field_labels_unique(fields)
      targets_ok = all_fields_targets_exist(fields, all_objects)
      Bool.and(one_name, Bool.and(labels_ok, targets_ok))

def all_objects_valid(objects: List<&2, ObjectSchema>, +all_objects: List<&2, ObjectSchema>) -> Bool:
  match objects:
    case Nil{}:
      True{}
    case Con{object, rest}:
      current_ok = object_is_valid(object, all_objects)
      rest_ok = all_objects_valid(rest, all_objects)
      Bool.and(current_ok, rest_ok)

def well_formed(schema: Schema) -> Bool:
  match schema:
    case Schema{+objects}:
      all_objects_valid(objects, objects)
