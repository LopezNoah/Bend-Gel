import Base
import ./Syntax.bend as S
import ./Schema.bend as D
import ../Cardinality.bend as C

type TypeContext is Data:
  Binding{var: S.Var, typ: S.QueryType, card: C.Card}

type TypeError is Data:
  UnboundVariable{var: S.Var}
  UnknownType{type_name: S.TypeName}
  UnknownLabel{type_name: S.TypeName, label: S.Label}
  ExpectedObject{}
  ExpectedBoolean{}
  TypeMismatch{}
  CardinalityMismatch{}
  InvalidBuiltin{}
  InvalidMutationTarget{}

type Synth is Data:
  SynthOK{typ: S.QueryType, card: C.Card}
  SynthError{error: TypeError}

def synth_bind(result: Synth, f: Synth -> Synth) -> Synth:
  f(result)

def type_eq(a: S.QueryType, b: S.QueryType) -> Bool:
  match a:
    case S.QScalar{scalar}:
      match b:
        case S.QScalar{other}: S.scalar_type_eq(scalar, other)
        case S.QObject{name, fields}: False{}
    case S.QObject{name, fields}:
      match b:
        case S.QScalar{scalar}: False{}
        case S.QObject{other, other_fields}: S.type_name_eq(name, other)

def query_type_of_stored(typ: S.StoredType) -> S.QueryType:
  match typ:
    case S.SScalar{scalar}: S.QScalar{scalar}
    case S.SLink{target, link_properties}: S.QObject{target, link_properties}
    case S.SField{label, inner, card}: query_type_of_stored(inner)

def append_stored_types(xs: List<&2, S.StoredType>, +ys: List<&2, S.StoredType>) -> List<&2, S.StoredType>:
  match xs:
    case Nil{}: ys
    case Con{head, tail}: Con{head, append_stored_types(tail, ys)}

def first_binding(bindings: List<&2, TypeContext>) -> Synth:
  match bindings:
    case Nil{}: SynthError{UnboundVariable{S.Var{"<missing>"}}}
    case Con{binding, rest}:
      match binding:
        case Binding{var, typ, card}: SynthOK{typ, card}

def prepend_binding_if(matches: Bool, binding: TypeContext, rest: List<&2, TypeContext>) -> List<&2, TypeContext>:
  match matches:
    case True{}: Con{binding, rest}
    case False{}: rest

def matching_bindings(+needle: S.Var, context: List<&2, TypeContext>) -> List<&2, TypeContext>:
  match context:
    case Nil{}: Nil{}
    case Con{binding, rest}:
      match binding:
        case Binding{+var, typ, card}:
          later = matching_bindings(needle, rest)
          same = S.var_eq(needle, var)
          current = {Binding{var, typ, card} : TypeContext}
          prepend_binding_if(same, current, later)

def lookup_variable_result(candidate: Synth, var: S.Var) -> Synth:
  match candidate:
    case SynthOK{typ, card}: candidate
    case SynthError{error}: SynthError{UnboundVariable{var}}

def lookup_variable(+var: S.Var, context: List<&2, TypeContext>) -> Synth:
  matches = matching_bindings(var, context)
  candidate = first_binding(matches)
  lookup_variable_result(candidate, var)

def card_join(a: C.Card, b: C.Card) -> C.Card:
  match a:
    case C.CEmpty{}:
      match b:
        case C.CEmpty{}: C.CEmpty{}
        case C.COptional{}: C.COptional{}
        case C.COne{}: C.COptional{}
        case C.CMany{}: C.CMany{}
        case C.CNonEmptyMany{}: C.CMany{}
    case C.COptional{}:
      match b:
        case C.CEmpty{}: C.COptional{}
        case C.COptional{}: C.COptional{}
        case C.COne{}: C.COptional{}
        case C.CMany{}: C.CMany{}
        case C.CNonEmptyMany{}: C.CMany{}
    case C.COne{}:
      match b:
        case C.CEmpty{}: C.COptional{}
        case C.COptional{}: C.COptional{}
        case C.COne{}: C.COne{}
        case C.CMany{}: C.CMany{}
        case C.CNonEmptyMany{}: C.CMany{}
    case C.CMany{}:
      C.CMany{}
    case C.CNonEmptyMany{}:
      match b:
        case C.CEmpty{}: C.CMany{}
        case C.COptional{}: C.CMany{}
        case C.COne{}: C.CMany{}
        case C.CMany{}: C.CMany{}
        case C.CNonEmptyMany{}: C.CNonEmptyMany{}

def project_from_field(source_card: C.Card, field: S.StoredType) -> Synth:
  match field:
    case S.SField{label, typ, card}:
      value_type = query_type_of_stored(typ)
      SynthOK{value_type, C.mul(source_card, card)}
    case S.SScalar{scalar}: SynthError{UnknownLabel{S.TypeName{"<object>"}, S.Label{"<label>"}}}
    case S.SLink{target, props}: SynthError{UnknownLabel{S.TypeName{"<object>"}, S.Label{"<label>"}}}

def project_field_candidate(candidate: Maybe<&2, S.StoredType>, source_card: C.Card, object_name: S.TypeName, label: S.Label) -> Synth:
  match candidate:
    case None{}: SynthError{UnknownLabel{object_name, label}}
    case Some{field}: project_from_field(source_card, field)

def get_schema_objects(schema: D.Schema) -> List<&2, D.ObjectSchema>:
  match schema:
    case D.Schema{objects}: objects

def project_from_source(schema: D.Schema, +label: S.Label, result: Synth) -> Synth:
  match result:
    case SynthError{error}: SynthError{error}
    case SynthOK{typ, card}:
      match typ:
        case S.QScalar{scalar}: SynthError{ExpectedObject{}}
        case S.QObject{+name, local_fields}:
          schema_fields = D.fields_for_name(name, get_schema_objects(schema))
          all_fields = append_stored_types(local_fields, schema_fields)
          matches = D.matching_fields(label, all_fields)
          candidate = D.first_field(matches)
          project_field_candidate(candidate, card, name, label)

def schema_objects(schema: D.Schema) -> List<&2, D.ObjectSchema>:
  match schema:
    case D.Schema{objects}: objects

def backlink_target_result(matches: Bool, owner: S.TypeName, props: List<&2, S.StoredType>) -> Synth:
  match matches:
    case True{}: SynthOK{S.QObject{owner, props}, C.CMany{}}
    case False{}: SynthError{TypeMismatch{}}

def backlink_field_candidate(candidate: Maybe<&2, S.StoredType>, source: Synth, owner: S.TypeName, label: S.Label) -> Synth:
  match candidate:
    case None{}: SynthError{UnknownLabel{owner, label}}
    case Some{field}:
      match field:
        case S.SField{field_label, stored, field_card}:
          match stored:
            case S.SLink{target, link_properties}:
              match source:
                case SynthError{error}: SynthError{error}
                case SynthOK{typ, card}:
                  match typ:
                    case S.QScalar{scalar}: SynthError{ExpectedObject{}}
                    case S.QObject{name, fields}:
                      same = S.type_name_eq(name, target)
                      backlink_target_result(same, owner, link_properties)
            case S.SScalar{scalar}: SynthError{TypeMismatch{}}
            case S.SField{nested_label, nested, nested_card}: SynthError{TypeMismatch{}}
        case S.SScalar{scalar}: SynthError{TypeMismatch{}}
        case S.SLink{target, props}: SynthError{TypeMismatch{}}

def backlink_target_ok(matches: Bool, owner: S.TypeName, props: List<&2, S.StoredType>) -> Synth:
  match matches:
    case True{}: SynthOK{S.QObject{owner, props}, C.CMany{}}
    case False{}: SynthError{TypeMismatch{}}

def union_same_result(same: Bool, typ: S.QueryType, left: C.Card, right: C.Card) -> Synth:
  match same:
    case True{}: SynthOK{typ, C.add(left, right)}
    case False{}: SynthError{TypeMismatch{}}

def union_results(left: Synth, right: Synth) -> Synth:
  match left:
    case SynthError{error}: SynthError{error}
    case SynthOK{+left_type, left_card}:
      match right:
        case SynthError{error}: SynthError{error}
        case SynthOK{right_type, right_card}:
          same = type_eq(left_type, right_type)
          union_same_result(same, left_type, left_card, right_card)

def union_same_type(same: Bool, typ: S.QueryType, left: C.Card, right: C.Card) -> Synth:
  match same:
    case True{}: SynthOK{typ, C.add(left, right)}
    case False{}: SynthError{TypeMismatch{}}

def branch_same_result(same: Bool, typ: S.QueryType, true_card: C.Card, false_card: C.Card) -> Synth:
  match same:
    case True{}: SynthOK{typ, card_join(true_card, false_card)}
    case False{}: SynthError{TypeMismatch{}}

def branches_result(when_true: Synth, when_false: Synth) -> Synth:
  match when_true:
    case SynthError{error}: SynthError{error}
    case SynthOK{+true_type, true_card}:
      match when_false:
        case SynthError{error}: SynthError{error}
        case SynthOK{false_type, false_card}:
          same = type_eq(true_type, false_type)
          branch_same_result(same, true_type, true_card, false_card)

def condition_valid(bool_type: Bool, singleton: Bool, when_true: Synth, when_false: Synth) -> Synth:
  match bool_type:
    case False{}: SynthError{ExpectedBoolean{}}
    case True{}:
      match singleton:
        case True{}: branches_result(when_true, when_false)
        case False{}: SynthError{CardinalityMismatch{}}

def condition_result(condition: Synth, when_true: Synth, when_false: Synth) -> Synth:
  match condition:
    case SynthError{error}: SynthError{error}
    case SynthOK{condition_type, condition_card}:
      match condition_type:
        case S.QScalar{scalar}:
          bool_type = S.scalar_type_eq(scalar, S.TBool{})
          singleton = C.le(condition_card, C.COne{})
          condition_valid(bool_type, singleton, when_true, when_false)
        case S.QObject{name, fields}: SynthError{ExpectedBoolean{}}

def condition_checks(bool_type: Bool, singleton: Bool, when_true: Synth, when_false: Synth) -> Synth:
  match bool_type:
    case False{}: SynthError{ExpectedBoolean{}}
    case True{}:
      match singleton:
        case True{}: branches_result(when_true, when_false)
        case False{}: SynthError{CardinalityMismatch{}}

def branch_result(when_true: Synth, when_false: Synth) -> Synth:
  match when_true:
    case SynthError{error}: SynthError{error}
    case SynthOK{+true_type, true_card}:
      match when_false:
        case SynthError{error}: SynthError{error}
        case SynthOK{false_type, false_card}:
          same = type_eq(true_type, false_type)
          branch_same_result(same, true_type, true_card, false_card)

def branch_same_type(same: Bool, typ: S.QueryType, true_card: C.Card, false_card: C.Card) -> Synth:
  match same:
    case True{}: SynthOK{typ, card_join(true_card, false_card)}
    case False{}: SynthError{TypeMismatch{}}

def any_type_ok(is_bool: Bool) -> Synth:
  match is_bool:
    case True{}: SynthOK{S.QScalar{S.TBool{}}, C.COne{}}
    case False{}: SynthError{TypeMismatch{}}

def any_builtin_result(typ: S.QueryType) -> Synth:
  match typ:
    case S.QScalar{scalar}:
      is_bool = S.scalar_type_eq(scalar, S.TBool{})
      any_type_ok(is_bool)
    case S.QObject{name, fields}: SynthError{TypeMismatch{}}

def one_builtin_result(builtin: S.Builtin, argument: Synth) -> Synth:
  match builtin:
    case S.BCount{}:
      match argument:
        case SynthError{error}: SynthError{error}
        case SynthOK{typ, card}: SynthOK{S.QScalar{S.TInt{}}, C.COne{}}
    case S.BAny{}:
      match argument:
        case SynthError{error}: SynthError{error}
        case SynthOK{typ, card}: any_builtin_result(typ)
    case S.BEq{}: SynthError{InvalidBuiltin{}}
    case S.BAdd{}: SynthError{InvalidBuiltin{}}
    case S.BConcat{}: SynthError{InvalidBuiltin{}}
    case S.BCoalesce{}: SynthError{InvalidBuiltin{}}

def any_builtin(typ: S.QueryType) -> Synth:
  match typ:
    case S.QScalar{scalar}:
      is_bool = S.scalar_type_eq(scalar, S.TBool{})
      any_type_ok(is_bool)
    case S.QObject{name, fields}: SynthError{TypeMismatch{}}

def any_builtin_type(is_bool: Bool) -> Synth:
  match is_bool:
    case True{}: SynthOK{S.QScalar{S.TBool{}}, C.COne{}}
    case False{}: SynthError{TypeMismatch{}}

def two_card_dispatch(cards: Bool, builtin: S.Builtin, left: S.QueryType, right: S.QueryType) -> Synth:
  match cards:
    case False{}: SynthError{CardinalityMismatch{}}
    case True{}:
      match builtin:
        case S.BEq{}: SynthOK{S.QScalar{S.TBool{}}, C.COne{}}
        case S.BAdd{}: SynthOK{S.QScalar{S.TInt{}}, C.COne{}}
        case S.BConcat{}: SynthOK{S.QScalar{S.TString{}}, C.COne{}}
        case S.BCoalesce{}: SynthOK{left, C.CMany{}}
        case S.BCount{}: SynthError{InvalidBuiltin{}}
        case S.BAny{}: SynthError{InvalidBuiltin{}}

def two_builtin_result(builtin: S.Builtin, left: Synth, right: Synth) -> Synth:
  match left:
    case SynthError{error}: SynthError{error}
    case SynthOK{left_type, left_card}:
      match right:
        case SynthError{error}: SynthError{error}
        case SynthOK{right_type, right_card}:
          left_one = C.le(left_card, C.COne{})
          right_one = C.le(right_card, C.COne{})
          cards = Bool.and(left_one, right_one)
          two_card_dispatch(cards, builtin, left_type, right_type)

def two_builtin_cards(cards: Bool, builtin: S.Builtin, left: S.QueryType, right: S.QueryType) -> Synth:
  two_card_dispatch(cards, builtin, left, right)

def eq_builtin_type(same: Bool) -> Synth:
  match same:
    case True{}: SynthOK{S.QScalar{S.TBool{}}, C.COne{}}
    case False{}: SynthError{TypeMismatch{}}

def int_pair_builtin(left: S.QueryType, right: S.QueryType, expected: S.ScalarType) -> Synth:
  SynthError{TypeMismatch{}}

def scalar_pair_result(ok: Bool, scalar: S.ScalarType) -> Synth:
  match ok:
    case True{}: SynthOK{S.QScalar{scalar}, C.COne{}}
    case False{}: SynthError{TypeMismatch{}}

def coalesce_type(same: Bool, typ: S.QueryType) -> Synth:
  match same:
    case True{}: SynthOK{typ, C.CMany{}}
    case False{}: SynthError{TypeMismatch{}}

def insert_known(known: Bool, schema: D.Schema, +object_type: S.TypeName) -> Synth:
  match known:
    case True{}:
      fields = D.fields_for_name(object_type, schema_objects(schema))
      SynthOK{S.QObject{object_type, fields}, C.COne{}}
    case False{}: SynthError{UnknownType{object_type}}

def insert_type_result(+schema: D.Schema, +object_type: S.TypeName) -> Synth:
  objects = schema_objects(schema)
  known = D.schema_has_name(object_type, objects)
  insert_known(known, schema, object_type)

def insert_type_known(known: Bool, schema: D.Schema, object_type: S.TypeName) -> Synth:
  insert_known(known, schema, object_type)

def type_root_known(known: Bool, schema: D.Schema, +object_type: S.TypeName) -> Synth:
  match known:
    case True{}:
      fields = D.fields_for_name(object_type, schema_objects(schema))
      SynthOK{S.QObject{object_type, fields}, C.CMany{}}
    case False{}:
      SynthError{UnknownType{object_type}}

def type_root_result(+schema: D.Schema, +object_type: S.TypeName) -> Synth:
  objects = schema_objects(schema)
  known = D.schema_has_name(object_type, objects)
  type_root_known(known, schema, object_type)

def update_single(single: Bool, typ: S.QueryType) -> Synth:
  match single:
    case False{}: SynthError{CardinalityMismatch{}}
    case True{}:
      match typ:
        case S.QScalar{scalar}: SynthError{InvalidMutationTarget{}}
        case S.QObject{name, fields}: SynthOK{typ, C.COptional{}}

def update_type_result(source: Synth) -> Synth:
  match source:
    case SynthError{error}: SynthError{error}
    case SynthOK{typ, card}:
      single = C.le(card, C.COne{})
      update_single(single, typ)

def update_single_result(single: Bool, typ: S.QueryType) -> Synth:
  match single:
    case False{}: SynthError{CardinalityMismatch{}}
    case True{}:
      match typ:
        case S.QScalar{scalar}: SynthError{InvalidMutationTarget{}}
        case S.QObject{name, fields}: SynthOK{typ, C.COptional{}}

# The syntax-directed synthesis algorithm. Shape/insert/update field lists are
# checked by evaluation against schema storage types in v0; their enclosing
# object type is synthesized here. The supported expression forms all produce
# a deterministic Synth or structured TypeError.
def synth(+schema: D.Schema, +context: List<&2, TypeContext>, expression: S.Expr) -> Synth:
  match expression:
    case S.EVar{var}:
      lookup_variable(var, context)
    case S.ELit{value}:
      scalar = S.scalar_type_of(value)
      SynthOK{S.QScalar{scalar}, C.COne{}}
    case S.EEmpty{typ}:
      SynthOK{typ, C.CEmpty{}}
    case S.ETypeRoot{name}:
      type_root_result(schema, name)
    case S.EUnion{left, right}:
      synth_bind(synth(schema, context, left), left_result => synth_bind(synth(schema, context, right), right_result => union_results(left_result, right_result)))
    case S.EProject{source, label}:
      synth_bind(synth(schema, context, source), result => project_from_source(schema, label, result))
    case S.EBacklink{source, +label, +owner}:
      source_result = synth(schema, context, source)
      candidate = D.lookup_field(schema, owner, label)
      backlink_field_candidate(candidate, source_result, owner, label)
    case S.EField{label, value}:
      synth(schema, context, value)
    case S.EShape{source, binder, fields}:
      synth(schema, context, source)
    case S.ECall{builtin, args}:
      match args:
        case Nil{}: SynthError{InvalidBuiltin{}}
        case Con{first, rest}:
          match rest:
            case Nil{}: synth_bind(synth(schema, context, first), result => one_builtin_result(builtin, result))
            case Con{second, remaining}:
              match remaining:
                case Nil{}: synth_bind(synth(schema, context, first), left_result => synth_bind(synth(schema, context, second), right_result => two_builtin_result(builtin, left_result, right_result)))
                case Con{third, tail}: SynthError{InvalidBuiltin{}}
    case S.EIfStrict{condition, when_true, when_false}:
      synth_bind(synth(schema, context, condition), condition_result_value => synth_bind(synth(schema, context, when_true), true_result => synth_bind(synth(schema, context, when_false), false_result => condition_result(condition_result_value, true_result, false_result))))
    case S.EWith{bound, binder, body}:
      synth(schema, context, bound)
    case S.EFor{source, binder, body}:
      synth(schema, context, source)
    case S.EFilter{source, binder, condition}:
      synth(schema, context, source)
    case S.EOrderBy{source, binder, key}:
      synth(schema, context, source)
    case S.EInsert{object_type, fields}:
      insert_type_result(schema, object_type)
    case S.EUpdate{source, binder, fields}:
      synth_bind(synth(schema, context, source), update_type_result)

def synth_with_body(schema: D.Schema, context: List<&2, TypeContext>, binder: S.Var, body: S.Expr, bound: Synth) -> Synth:
  match bound:
    case SynthError{error}: SynthError{error}
    case SynthOK{typ, card}: synth(schema, Con{Binding{binder, typ, card}, context}, body)

def for_body_result(source_card: C.Card, body_result: Synth) -> Synth:
  match body_result:
    case SynthError{error}: SynthError{error}
    case SynthOK{body_type, body_card}: SynthOK{body_type, C.mul(source_card, body_card)}

def synth_for_body(schema: D.Schema, context: List<&2, TypeContext>, binder: S.Var, body: S.Expr, source: Synth) -> Synth:
  match source:
    case SynthError{error}: SynthError{error}
    case SynthOK{source_type, source_card}:
       body_result = synth(schema, Con{Binding{binder, source_type, C.COne{}}, context}, body)
       for_body_result(source_card, body_result)

def order_key_accepts(optional: Bool, source_type: S.QueryType, source_card: C.Card) -> Synth:
  match optional:
    case True{}: SynthOK{source_type, source_card}
    case False{}: SynthError{CardinalityMismatch{}}

def order_body_result(source_type: S.QueryType, source_card: C.Card, key_result: Synth) -> Synth:
  match key_result:
    case SynthError{error}: SynthError{error}
    case SynthOK{key_type, key_card}:
      optional = C.le(key_card, C.COptional{})
      order_key_accepts(optional, source_type, source_card)

def synth_order_body(schema: D.Schema, context: List<&2, TypeContext>, binder: S.Var, key: S.Expr, source: Synth) -> Synth:
  match source:
    case SynthError{error}: SynthError{error}
    case SynthOK{+source_type, source_card}:
      key_result = synth(schema, Con{Binding{binder, source_type, C.COne{}}, context}, key)
      order_body_result(source_type, source_card, key_result)

def order_key_result(optional: Bool, source_type: S.QueryType, source_card: C.Card) -> Synth:
  match optional:
    case True{}: SynthOK{source_type, source_card}
    case False{}: SynthError{CardinalityMismatch{}}
