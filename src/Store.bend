import Base
import ./Syntax.bend as S
import ./Value.bend as V

type EditMark is Data:
  Unlocked{}
  Locked{}

type StoredObject is Data:
  StoredObject{id: S.ObjectId, object_type: S.TypeName, mark: EditMark, fields: List<&2, V.StoredValue>}

type Store is Data:
  Store{objects: List<&2, StoredObject>, next_id: Nat}

type StoreChange is Data:
  StoreChange{objects: List<&2, StoredObject>, values: List<&2, V.ComputedValue>, changed: Bool}

type InsertResult is Data:
  InsertResult{value: V.ComputedValue, store: Store}

def append_objects(xs: List<&2, StoredObject>, +ys: List<&2, StoredObject>) -> List<&2, StoredObject>:
  match xs:
    case Nil{}: ys
    case Con{head, tail}: Con{head, append_objects(tail, ys)}

def append_computed(xs: List<&2, V.ComputedValue>, +ys: List<&2, V.ComputedValue>) -> List<&2, V.ComputedValue>:
  V.append_values(xs, ys)

def stored_values_to_computed(values: List<&2, V.StoredValue>) -> List<&2, V.ComputedValue>:
  match values:
    case Nil{}:
      Nil{}
    case Con{value, rest}:
      match value:
        case V.SVScalar{scalar}:
          Con{V.CVScalar{scalar}, stored_values_to_computed(rest)}
        case V.SVRef{target, link_properties}:
          props = stored_values_to_computed(link_properties)
          Con{V.CVObject{target, props}, stored_values_to_computed(rest)}
        case V.SVField{label, nested}:
          values = stored_values_to_computed(nested)
          Con{V.CVField{label, V.Visible{}, values}, stored_values_to_computed(rest)}

def append_projection_if(matches: Bool, selected: List<&2, V.ComputedValue>, rest: List<&2, V.ComputedValue>) -> List<&2, V.ComputedValue>:
  match matches:
    case True{}: append_computed(selected, rest)
    case False{}: rest

def project_stored_fields(+label: S.Label, fields: List<&2, V.StoredValue>) -> List<&2, V.ComputedValue>:
  match fields:
    case Nil{}:
      Nil{}
    case Con{field, rest}:
      match field:
        case V.SVField{found, values}:
          rest_values = project_stored_fields(label, rest)
          selected = stored_values_to_computed(values)
          same = S.label_eq(label, found)
          append_projection_if(same, selected, rest_values)
        case V.SVScalar{scalar}:
          project_stored_fields(label, rest)
        case V.SVRef{target, link_properties}:
          project_stored_fields(label, rest)

def prepend_object_if(matches: Bool, object: StoredObject, rest: List<&2, StoredObject>) -> List<&2, StoredObject>:
  match matches:
    case True{}: Con{object, rest}
    case False{}: rest

def matching_id_objects(+id: S.ObjectId, objects: List<&2, StoredObject>) -> List<&2, StoredObject>:
  match objects:
    case Nil{}:
      Nil{}
    case Con{+object, rest}:
      match object:
        case StoredObject{object_id, object_type, mark, fields}:
          later = matching_id_objects(id, rest)
          same = S.object_id_eq(id, object_id)
          current = {StoredObject{object_id, object_type, mark, fields} : StoredObject}
          prepend_object_if(same, current, later)

def first_object_fields(objects: List<&2, StoredObject>) -> List<&2, V.StoredValue>:
  match objects:
    case Nil{}: Nil{}
    case Con{object, rest}:
      match object:
        case StoredObject{id, object_type, mark, fields}: fields

def stored_fields_for_id(id: S.ObjectId, store: Store) -> List<&2, V.StoredValue>:
  match store:
    case Store{objects, next_id}:
      matches = matching_id_objects(id, objects)
      first_object_fields(matches)

def choose_projection(has_local: Bool, local: List<&2, V.ComputedValue>, stored: List<&2, V.ComputedValue>) -> List<&2, V.ComputedValue>:
  match has_local:
    case True{}: local
    case False{}: stored

def project_from_value(initial: Store, +label: S.Label, value: V.ComputedValue) -> List<&2, V.ComputedValue>:
  match value:
    case V.CVScalar{scalar}:
      Nil{}
    case V.CVField{field_label, visibility, values}:
      Nil{}
    case V.CVObject{id, +local_fields}:
      local = V.project_fields(label, local_fields)
      stored_fields = stored_fields_for_id(id, initial)
      stored = project_stored_fields(label, stored_fields)
      has_local = V.field_list_has_label(label, local_fields)
      choose_projection(has_local, local, stored)

def project_values(+initial: Store, +label: S.Label, values: List<&2, V.ComputedValue>) -> List<&2, V.ComputedValue>:
  match values:
    case Nil{}:
      Nil{}
    case Con{value, rest}:
      current = project_from_value(initial, label, value)
      later = project_values(initial, label, rest)
      append_computed(current, later)

def root_values_in(+name: S.TypeName, objects: List<&2, StoredObject>) -> List<&2, V.ComputedValue>:
  match objects:
    case Nil{}:
      Nil{}
    case Con{object, rest}:
      match object:
        case StoredObject{id, object_type, mark, fields}:
          later = root_values_in(name, rest)
          same = S.type_name_eq(name, object_type)
          root_value = {V.CVObject{id, Nil{}} : V.ComputedValue}
          root_singleton = {Con{root_value, Nil{}} : List<&2, V.ComputedValue>}
          append_projection_if(same, root_singleton, later)

def root_values(name: S.TypeName, store: Store) -> List<&2, V.ComputedValue>:
  match store:
    case Store{objects, next_id}:
      root_values_in(name, objects)

def root_values_in_objects(+name: S.TypeName, objects: List<&2, StoredObject>) -> List<&2, V.ComputedValue>:
  match objects:
    case Nil{}:
      Nil{}
    case Con{object, rest}:
      match object:
        case StoredObject{id, object_type, mark, fields}:
          later = root_values_in_objects(name, rest)
          same = S.type_name_eq(name, object_type)
          root_value = {V.CVObject{id, Nil{}} : V.ComputedValue}
          root_singleton = {Con{root_value, Nil{}} : List<&2, V.ComputedValue>}
          append_projection_if(same, root_singleton, later)

def ref_matches_id(needle: S.ObjectId, value: V.StoredValue) -> Bool:
  match value:
    case V.SVScalar{scalar}: False{}
    case V.SVField{label, values}: False{}
    case V.SVRef{target, link_properties}: S.object_id_eq(needle, target)

def reference_result_if(matches: Bool, target: S.ObjectId, props: List<&2, V.StoredValue>, rest: List<&2, V.ComputedValue>) -> List<&2, V.ComputedValue>:
  match matches:
    case True{}:
      computed_props = stored_values_to_computed(props)
      Con{V.CVObject{target, computed_props}, rest}
    case False{}:
      rest

def references_to(+needle: S.ObjectId, values: List<&2, V.StoredValue>) -> List<&2, V.ComputedValue>:
  match values:
    case Nil{}:
      Nil{}
    case Con{value, rest}:
      match value:
        case V.SVRef{+target, props}:
          later = references_to(needle, rest)
          same = S.object_id_eq(needle, target)
          reference_result_if(same, target, props, later)
        case V.SVScalar{scalar}:
          references_to(needle, rest)
        case V.SVField{label, nested}:
          references_to(needle, rest)

def select_stored(matches: Bool, selected: List<&2, V.StoredValue>, rest: List<&2, V.StoredValue>) -> List<&2, V.StoredValue>:
  match matches:
    case True{}: V.append_stored_values(selected, rest)
    case False{}: rest

def refs_for_label(+label: S.Label, fields: List<&2, V.StoredValue>) -> List<&2, V.StoredValue>:
  match fields:
    case Nil{}:
      Nil{}
    case Con{field, rest}:
      match field:
        case V.SVField{found, values}:
          later = refs_for_label(label, rest)
          same = S.label_eq(label, found)
          select_stored(same, values, later)
        case V.SVScalar{scalar}:
          refs_for_label(label, rest)
        case V.SVRef{target, link_properties}:
          refs_for_label(label, rest)

def select_stored_if(matches: Bool, selected: List<&2, V.StoredValue>, rest: List<&2, V.StoredValue>) -> List<&2, V.StoredValue>:
  match matches:
    case True{}: V.append_stored_values(selected, rest)
    case False{}: rest

def backlink_current_if(is_owner: Bool, needle: S.ObjectId, label: S.Label, fields: List<&2, V.StoredValue>) -> List<&2, V.ComputedValue>:
  match is_owner:
    case True{}:
      candidates = refs_for_label(label, fields)
      references_to(needle, candidates)
    case False{}:
      Nil{}

def backlink_in_objects(+needle: S.ObjectId, +label: S.Label, +owner: S.TypeName, objects: List<&2, StoredObject>) -> List<&2, V.ComputedValue>:
  match objects:
    case Nil{}:
      Nil{}
    case Con{object, rest}:
      match object:
        case StoredObject{id, object_type, mark, fields}:
          current_owner = S.type_name_eq(owner, object_type)
          current = backlink_current_if(current_owner, needle, label, fields)
          later = backlink_in_objects(needle, label, owner, rest)
          append_computed(current, later)

def backlink_values(needle: S.ObjectId, label: S.Label, owner: S.TypeName, initial: Store) -> List<&2, V.ComputedValue>:
  match initial:
    case Store{objects, next_id}: backlink_in_objects(needle, label, owner, objects)

def backlink_from_values(+initial: Store, +label: S.Label, +owner: S.TypeName, values: List<&2, V.ComputedValue>) -> List<&2, V.ComputedValue>:
  match values:
    case Nil{}:
      Nil{}
    case Con{value, rest}:
      match value:
        case V.CVObject{id, fields}:
          current = backlink_values(id, label, owner, initial)
          later = backlink_from_values(initial, label, owner, rest)
          append_computed(current, later)
        case V.CVScalar{scalar}:
          backlink_from_values(initial, label, owner, rest)
        case V.CVField{field_label, visibility, field_values}:
          backlink_from_values(initial, label, owner, rest)

def store_insert(store: Store, object_type: S.TypeName, +fields: List<&2, V.StoredValue>) -> InsertResult:
  match store:
    case Store{objects, +next_id}:
      +id = {S.ObjectId{next_id} : S.ObjectId}
      object = {StoredObject{id, object_type, Locked{}, fields} : StoredObject}
      new_objects = append_objects(objects, Con{object, Nil{}})
      computed_fields = stored_values_to_computed(fields)
      value = {V.CVObject{id, computed_fields} : V.ComputedValue}
      InsertResult{value, Store{new_objects, 1n+next_id}}

def stored_field_list_has_label(+label: S.Label, fields: List<&2, V.StoredValue>) -> Bool:
  match fields:
    case Nil{}:
      False{}
    case Con{field, rest}:
      match field:
        case V.SVField{found, values}:
          same = S.label_eq(label, found)
          later = stored_field_list_has_label(label, rest)
          Bool.or(same, later)
        case V.SVScalar{scalar}: stored_field_list_has_label(label, rest)
        case V.SVRef{target, props}: stored_field_list_has_label(label, rest)

def keep_stored_if(removed: Bool, field: V.StoredValue) -> List<&2, V.StoredValue>:
  match removed:
    case True{}: Nil{}
    case False{}: Con{field, Nil{}}

def remove_overridden_stored(old: List<&2, V.StoredValue>, +added: List<&2, V.StoredValue>) -> List<&2, V.StoredValue>:
  match old:
    case Nil{}:
      Nil{}
    case Con{field, rest}:
      match field:
        case V.SVField{+label, values}:
          later = remove_overridden_stored(rest, added)
          overridden = stored_field_list_has_label(label, added)
          kept = keep_stored_if(overridden, V.SVField{label, values})
          V.append_stored_values(kept, later)
        case V.SVScalar{scalar}: remove_overridden_stored(rest, added)
        case V.SVRef{target, props}: remove_overridden_stored(rest, added)

def stored_record_extend(old: List<&2, V.StoredValue>, +added: List<&2, V.StoredValue>) -> List<&2, V.StoredValue>:
  retained = remove_overridden_stored(old, added)
  V.append_stored_values(retained, added)

def update_existing(object: StoredObject, +added: List<&2, V.StoredValue>) -> StoreChange:
  match object:
    case StoredObject{+id, object_type, mark, old_fields}:
      match mark:
        case Unlocked{}:
          new_fields = stored_record_extend(old_fields, added)
          output_fields = stored_values_to_computed(added)
          value = {V.CVObject{id, output_fields} : V.ComputedValue}
          replacement = {StoredObject{id, object_type, Locked{}, new_fields} : StoredObject}
          StoreChange{Con{replacement, Nil{}}, Con{value, Nil{}}, True{}}
        case Locked{}:
          StoreChange{Con{object, Nil{}}, Nil{}, False{}}

def choose_update_object(matches: Bool, current: StoreChange, original: StoredObject, rest: List<&2, StoredObject>, tail_change: StoreChange) -> StoreChange:
  match matches:
    case True{}:
      match current:
        case StoreChange{changed_objects, values, changed}:
          objects = append_objects(changed_objects, rest)
          StoreChange{objects, values, changed}
    case False{}:
      match tail_change:
        case StoreChange{changed_objects, values, changed}:
          StoreChange{Con{original, changed_objects}, values, changed}

def update_object_list(+id: S.ObjectId, +added: List<&2, V.StoredValue>, objects: List<&2, StoredObject>) -> StoreChange:
  match objects:
    case Nil{}:
      StoreChange{Nil{}, Nil{}, False{}}
    case Con{+object, +rest}:
      match object:
        case StoredObject{+object_id, object_type, mark, fields}:
          same = S.object_id_eq(id, object_id)
          +current_object = {StoredObject{object_id, object_type, mark, fields} : StoredObject}
          current = update_existing(current_object, added)
          tail_change = update_object_list(id, added, rest)
          choose_update_object(same, current, current_object, rest, tail_change)

def store_update(store: Store, id: S.ObjectId, added: List<&2, V.StoredValue>) -> StoreChange:
  match store:
    case Store{objects, next_id}:
      update_object_list(id, added, objects)

def apply_change(store: Store, change: StoreChange) -> Store:
  match store:
    case Store{objects, next_id}:
      match change:
        case StoreChange{new_objects, values, changed}: Store{new_objects, next_id}
