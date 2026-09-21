import Base
import ./Syntax.bend as S
import ./Schema.bend as D
import ./Store.bend as M
import ./Value.bend as V

# An explicit continuation machine keeps the paper's left-to-right state
# threading while avoiding mutually recursive Bend definitions.
type EvalEnv is Data:
  ValueBinding{var: S.Var, values: List<&2, V.ComputedValue>}

type EvalError is Data:
  UnboundRuntimeVariable{var: S.Var}
  RuntimeTypeError{}
  RuntimeCardinalityError{}
  UnsupportedFieldExpression{}
  StepLimitExceeded{}

type EvalResult is Data:
  EvalResult{values: List<&2, V.ComputedValue>, store: M.Store}

type EvalOutcome is Data:
  EvalOK{result: EvalResult}
  EvalError{error: EvalError}

type StoredBuild is Data:
  StoredBuilt{values: List<&2, V.StoredValue>}
  StoredFailed{}

type StoredInput is Data:
  OneComputed{value: V.ComputedValue}
  ManyComputed{values: List<&2, V.ComputedValue>}

type MutationTarget is Data:
  InsertTarget{object_type: S.TypeName}
  UpdateTarget{id: S.ObjectId}

type SortKey is Data:
  KeyEmpty{}
  KeyInt{value: Nat}
  KeyBool{value: Bool}
  KeyString{value: String}
  KeyInvalid{}

type OrderEntry is Data:
  OrderEntry{value: V.ComputedValue, key: SortKey}

def append_entries(xs: List<&2, OrderEntry>, +ys: List<&2, OrderEntry>) -> List<&2, OrderEntry>:
  match xs:
    case Nil{}: ys
    case Con{head, tail}: Con{head, append_entries(tail, ys)}

type OrderState is Data:
  OrderInsert{value: V.ComputedValue, key: SortKey, sorted: List<&2, OrderEntry>}
  OrderCompare{before: Bool, value: V.ComputedValue, key: SortKey, head_value: V.ComputedValue, head_key: SortKey, tail: List<&2, OrderEntry>}

type FieldSplit is Data:
  AField{label: S.Label, value: S.Expr}
  NotAField{}

type Continuation is Data:
  End{}
  KUnionLeft{right: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KUnionRight{left_values: List<&2, V.ComputedValue>, next: Continuation}
  KProject{label: S.Label, next: Continuation}
  KBacklink{label: S.Label, owner: S.TypeName, next: Continuation}
  KIf{when_true: S.Expr, when_false: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KWith{binder: S.Var, body: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KForSource{binder: S.Var, body: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KForBody{remaining: List<&2, V.ComputedValue>, binder: S.Var, body: S.Expr, environment: List<&2, EvalEnv>, collected: List<&2, V.ComputedValue>, next: Continuation}
  KFilterSource{binder: S.Var, condition: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KFilterCondition{value: V.ComputedValue, remaining: List<&2, V.ComputedValue>, binder: S.Var, condition: S.Expr, environment: List<&2, EvalEnv>, collected: List<&2, V.ComputedValue>, next: Continuation}
  KOrderSource{binder: S.Var, key: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KOrderKey{value: V.ComputedValue, remaining: List<&2, V.ComputedValue>, binder: S.Var, key: S.Expr, environment: List<&2, EvalEnv>, collected: List<&2, OrderEntry>, next: Continuation}
  KShapeSource{binder: S.Var, fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, next: Continuation}
  KShapeField{label: S.Label, source: V.ComputedValue, remaining_fields: List<&2, S.Expr>, source_tail: List<&2, V.ComputedValue>, binder: S.Var, all_fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, collected_fields: List<&2, V.ComputedValue>, shaped: List<&2, V.ComputedValue>, next: Continuation}
  KCallOne{builtin: S.Builtin, next: Continuation}
  KCallLeft{builtin: S.Builtin, second: S.Expr, environment: List<&2, EvalEnv>, next: Continuation}
  KCallRight{builtin: S.Builtin, left_values: List<&2, V.ComputedValue>, next: Continuation}
  KUpdateSource{binder: S.Var, fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, next: Continuation}
  KMutationField{target: MutationTarget, label: S.Label, remaining_fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, collected: List<&2, V.StoredValue>, next: Continuation}

type NextContinuation is Data:
  NoContinuation{}
  HasContinuation{next: Continuation}

type Machine is Data:
  Evaluate{current: M.Store, environment: List<&2, EvalEnv>, expression: S.Expr, next: Continuation}
  Return{outcome: EvalOutcome, next: Continuation}
  Raise{error: EvalError, next: Continuation}
  RunFor{remaining: List<&2, V.ComputedValue>, binder: S.Var, body: S.Expr, environment: List<&2, EvalEnv>, current: M.Store, collected: List<&2, V.ComputedValue>, next: Continuation}
  RunFilter{remaining: List<&2, V.ComputedValue>, binder: S.Var, condition: S.Expr, environment: List<&2, EvalEnv>, current: M.Store, collected: List<&2, V.ComputedValue>, next: Continuation}
  RunOrder{remaining: List<&2, V.ComputedValue>, binder: S.Var, key: S.Expr, environment: List<&2, EvalEnv>, current: M.Store, collected: List<&2, OrderEntry>, next: Continuation}
  RunShape{remaining: List<&2, V.ComputedValue>, binder: S.Var, fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, current: M.Store, shaped: List<&2, V.ComputedValue>, next: Continuation}
  BuildShape{source: V.ComputedValue, remaining_fields: List<&2, S.Expr>, source_tail: List<&2, V.ComputedValue>, binder: S.Var, all_fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, current: M.Store, collected_fields: List<&2, V.ComputedValue>, shaped: List<&2, V.ComputedValue>, next: Continuation}
  BuildMutation{target: MutationTarget, remaining_fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, current: M.Store, collected: List<&2, V.StoredValue>, next: Continuation}

def continuation_tail(kont: Continuation) -> NextContinuation:
  match kont:
    case End{}: NoContinuation{}
    case KUnionLeft{right, environment, next}: HasContinuation{next}
    case KUnionRight{left_values, next}: HasContinuation{next}
    case KProject{label, next}: HasContinuation{next}
    case KBacklink{label, owner, next}: HasContinuation{next}
    case KIf{when_true, when_false, environment, next}: HasContinuation{next}
    case KWith{binder, body, environment, next}: HasContinuation{next}
    case KForSource{binder, body, environment, next}: HasContinuation{next}
    case KForBody{remaining, binder, body, environment, collected, next}: HasContinuation{next}
    case KFilterSource{binder, condition, environment, next}: HasContinuation{next}
    case KFilterCondition{value, remaining, binder, condition, environment, collected, next}: HasContinuation{next}
    case KOrderSource{binder, key, environment, next}: HasContinuation{next}
    case KOrderKey{value, remaining, binder, key, environment, collected, next}: HasContinuation{next}
    case KShapeSource{binder, fields, environment, next}: HasContinuation{next}
    case KShapeField{label, source, remaining_fields, source_tail, binder, all_fields, environment, collected_fields, shaped, next}: HasContinuation{next}
    case KCallOne{builtin, next}: HasContinuation{next}
    case KCallLeft{builtin, second, environment, next}: HasContinuation{next}
    case KCallRight{builtin, left_values, next}: HasContinuation{next}
    case KUpdateSource{binder, fields, environment, next}: HasContinuation{next}
    case KMutationField{target, label, remaining_fields, environment, collected, next}: HasContinuation{next}

def prepend_env_if(matches: Bool, binding: EvalEnv, rest: List<&2, EvalEnv>) -> List<&2, EvalEnv>:
  match matches:
    case True{}: Con{binding, rest}
    case False{}: rest

def matching_env(+needle: S.Var, environment: List<&2, EvalEnv>) -> List<&2, EvalEnv>:
  match environment:
    case Nil{}: Nil{}
    case Con{binding, rest}:
      match binding:
        case ValueBinding{+var, values}:
          later = matching_env(needle, rest)
          same = S.var_eq(needle, var)
          current = {ValueBinding{var, values} : EvalEnv}
          prepend_env_if(same, current, later)

def first_env_binding(matches: List<&2, EvalEnv>, current: M.Store, missing: S.Var) -> EvalOutcome:
  match matches:
    case Nil{}: EvalError{UnboundRuntimeVariable{missing}}
    case Con{binding, rest}:
      match binding:
        case ValueBinding{var, values}: EvalOK{EvalResult{values, current}}

def lookup_env(+needle: S.Var, environment: List<&2, EvalEnv>, current: M.Store) -> EvalOutcome:
  first_env_binding(matching_env(needle, environment), current, needle)

def any_true(values: List<&2, V.ComputedValue>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{value, rest}:
      match value:
        case V.CVScalar{scalar}:
          match scalar:
            case S.VBool{flag}: Bool.or(flag, any_true(rest))
            case S.VInt{n}: any_true(rest)
            case S.VString{text}: any_true(rest)
        case V.CVObject{id, fields}: any_true(rest)
        case V.CVField{label, visibility, fields}: any_true(rest)

def binary_pair(builtin: S.Builtin, left: V.ComputedValue, right: V.ComputedValue) -> EvalOutcome:
  match builtin:
    case S.BEq{}:
      equal = V.value_identity_equal(left, right)
      EvalOK{EvalResult{Con{V.CVScalar{S.VBool{equal}}, Nil{}}, M.Store{Nil{}, 0n}}}
    case S.BAdd{}:
      match left:
        case V.CVScalar{S.VInt{a}}:
          match right:
            case V.CVScalar{S.VInt{b}}: EvalOK{EvalResult{Con{V.CVScalar{S.VInt{(a + b : Nat)}}, Nil{}}, M.Store{Nil{}, 0n}}}
            case _: EvalError{RuntimeTypeError{}}
        case _: EvalError{RuntimeTypeError{}}
    case S.BConcat{}:
      match left:
        case V.CVScalar{S.VString{a}}:
          match right:
            case V.CVScalar{S.VString{b}}: EvalOK{EvalResult{Con{V.CVScalar{S.VString{a ++ b}}, Nil{}}, M.Store{Nil{}, 0n}}}
            case _: EvalError{RuntimeTypeError{}}
        case _: EvalError{RuntimeTypeError{}}
    case _: EvalError{RuntimeCardinalityError{}}

def binary_values(builtin: S.Builtin, values: List<&2, V.ComputedValue>) -> EvalOutcome:
  match values:
    case Con{left, Con{right, Nil{}}}: binary_pair(builtin, left, right)
    case _: EvalError{RuntimeCardinalityError{}}

def builtin_one(builtin: S.Builtin, values: List<&2, V.ComputedValue>) -> EvalOutcome:
  match builtin:
    case S.BCount{}: EvalOK{EvalResult{Con{V.CVScalar{S.VInt{V.value_length(values)}}, Nil{}}, M.Store{Nil{}, 0n}}}
    case S.BAny{}: EvalOK{EvalResult{Con{V.CVScalar{S.VBool{any_true(values)}}, Nil{}}, M.Store{Nil{}, 0n}}}
    case _: EvalError{RuntimeCardinalityError{}}

def builtin_two(builtin: S.Builtin, left: List<&2, V.ComputedValue>, right: List<&2, V.ComputedValue>) -> EvalOutcome:
  match builtin:
    case S.BCoalesce{}:
      match left:
        case Nil{}: EvalOK{EvalResult{right, M.Store{Nil{}, 0n}}}
        case Con{head, tail}: EvalOK{EvalResult{left, M.Store{Nil{}, 0n}}}
    case _: binary_values(builtin, V.append_values(left, right))

def attach_store(outcome: EvalOutcome, current: M.Store) -> EvalOutcome:
  match outcome:
    case EvalError{error}: EvalError{error}
    case EvalOK{result}:
      match result:
        case EvalResult{values, ignored}: EvalOK{EvalResult{values, current}}

def continue_if(current: M.Store, values: List<&2, V.ComputedValue>, when_true: S.Expr, when_false: S.Expr, environment: List<&2, EvalEnv>, later: Continuation) -> Machine:
  match values:
    case Con{V.CVScalar{S.VBool{True{}}}, Nil{}}: Evaluate{current, environment, when_true, later}
    case Con{V.CVScalar{S.VBool{False{}}}, Nil{}}: Evaluate{current, environment, when_false, later}
    case Con{head, tail}: Raise{RuntimeTypeError{}, later}
    case Nil{}: Raise{RuntimeCardinalityError{}, later}

def continue_update_source(current: M.Store, values: List<&2, V.ComputedValue>, binder: S.Var, fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, later: Continuation) -> Machine:
  match values:
    case Con{V.CVObject{+id, object_fields}, Nil{}}: BuildMutation{UpdateTarget{id}, fields, Con{ValueBinding{binder, Con{V.CVObject{id, object_fields}, Nil{}}}, environment}, current, Nil{}, later}
    case Con{value, Nil{}}: Raise{RuntimeTypeError{}, later}
    case _: Raise{RuntimeCardinalityError{}, later}

def continue_filter_condition(current: M.Store, matches: Bool, value: V.ComputedValue, remaining: List<&2, V.ComputedValue>, binder: S.Var, condition: S.Expr, environment: List<&2, EvalEnv>, collected: List<&2, V.ComputedValue>, later: Continuation) -> Machine:
  match matches:
    case True{}: RunFilter{remaining, binder, condition, environment, current, V.append_values(collected, Con{value, Nil{}}), later}
    case False{}: RunFilter{remaining, binder, condition, environment, current, collected, later}

def continue_order_key(current: M.Store, key: SortKey, value: V.ComputedValue, remaining: List<&2, V.ComputedValue>, binder: S.Var, expression: S.Expr, environment: List<&2, EvalEnv>, collected: List<&2, OrderEntry>, later: Continuation) -> Machine:
  match key:
    case KeyInvalid{}: Raise{RuntimeTypeError{}, later}
    case computed_key: RunOrder{remaining, binder, expression, environment, current, append_entries(collected, Con{OrderEntry{value, computed_key}, Nil{}}), later}

def continue_mutation_field(current: M.Store, stored: StoredBuild, target: MutationTarget, label: S.Label, remaining_fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, collected: List<&2, V.StoredValue>, later: Continuation) -> Machine:
  match stored:
    case StoredFailed{}: Raise{RuntimeTypeError{}, later}
    case StoredBuilt{stored_values}: BuildMutation{target, remaining_fields, environment, current, V.append_stored_values(collected, Con{V.SVField{label, stored_values}, Nil{}}), later}

def continue_raise(error: EvalError, tail: NextContinuation) -> Machine:
  match tail:
    case NoContinuation{}: Raise{error, End{}}
    case HasContinuation{later}: Raise{error, later}

def continue_shape_value(current: M.Store, outcome: EvalOutcome, source_tail: List<&2, V.ComputedValue>, binder: S.Var, all_fields: List<&2, S.Expr>, environment: List<&2, EvalEnv>, shaped: List<&2, V.ComputedValue>, next: Continuation) -> Machine:
  match outcome:
    case EvalError{error}: Raise{error, next}
    case EvalOK{EvalResult{new_values, ignored}}: RunShape{source_tail, binder, all_fields, environment, current, V.append_values(shaped, new_values), next}

def continue_shape_field(current: M.Store, field: FieldSplit, source: V.ComputedValue, remaining_fields: List<&2, S.Expr>, source_tail: List<&2, V.ComputedValue>, binder: S.Var, all_fields: List<&2, S.Expr>, +environment: List<&2, EvalEnv>, collected_fields: List<&2, V.ComputedValue>, shaped: List<&2, V.ComputedValue>, next: Continuation) -> Machine:
  match field:
    case AField{label, value}: Evaluate{current, environment, value, KShapeField{label, source, remaining_fields, source_tail, binder, all_fields, environment, collected_fields, shaped, next}}
    case NotAField{}: Raise{UnsupportedFieldExpression{}, next}

def continue_mutation_expression(current: M.Store, field: FieldSplit, target: MutationTarget, remaining_fields: List<&2, S.Expr>, +environment: List<&2, EvalEnv>, collected: List<&2, V.StoredValue>, next: Continuation) -> Machine:
  match field:
    case AField{label, value}: Evaluate{current, environment, value, KMutationField{target, label, remaining_fields, environment, collected, next}}
    case NotAField{}: Raise{UnsupportedFieldExpression{}, next}

def prepend_stored(first: StoredBuild, rest: StoredBuild) -> StoredBuild:
  match first:
    case StoredFailed{}: StoredFailed{}
    case StoredBuilt{first_values}:
      match rest:
        case StoredFailed{}: StoredFailed{}
        case StoredBuilt{rest_values}: StoredBuilt{V.append_stored_values(first_values, rest_values)}

def stored_reference(id: S.ObjectId, fields: StoredBuild) -> StoredBuild:
  match fields:
    case StoredFailed{}: StoredFailed{}
    case StoredBuilt{properties}: StoredBuilt{Con{V.SVRef{id, properties}, Nil{}}}

def stored_convert(+fuel: Nat, input: StoredInput) -> StoredBuild:
  match fuel:
    case 0n:
      StoredFailed{}
    case 1n+remaining:
      match input:
        case OneComputed{value}:
          match value:
            case V.CVScalar{scalar}: StoredBuilt{Con{V.SVScalar{scalar}, Nil{}}}
            case V.CVObject{id, fields}: stored_reference(id, stored_convert(remaining, ManyComputed{fields}))
            case V.CVField{label, visibility, fields}: StoredFailed{}
        case ManyComputed{values}:
          match values:
            case Nil{}: StoredBuilt{Nil{}}
            case Con{value, rest}: prepend_stored(stored_convert(remaining, OneComputed{value}), stored_convert(remaining, ManyComputed{rest}))

def computed_to_stored(value: V.ComputedValue) -> StoredBuild:
  stored_convert(100000n, OneComputed{value})

def computed_values_to_stored(values: List<&2, V.ComputedValue>) -> StoredBuild:
  stored_convert(100000n, ManyComputed{values})

def split_field(expression: S.Expr) -> FieldSplit:
  match expression:
    case S.EField{label, value}: AField{label, value}
    case _: NotAField{}

def shape_value(source: V.ComputedValue, fields: List<&2, V.ComputedValue>) -> EvalOutcome:
  match source:
    case V.CVObject{id, old_fields}: EvalOK{EvalResult{Con{V.CVObject{id, V.record_extend(old_fields, fields)}, Nil{}}, M.Store{Nil{}, 0n}}}
    case _: EvalError{RuntimeTypeError{}}

def key_of(values: List<&2, V.ComputedValue>) -> SortKey:
  match values:
    case Nil{}: KeyEmpty{}
    case Con{V.CVScalar{S.VInt{n}}, Nil{}}: KeyInt{n}
    case Con{V.CVScalar{S.VBool{flag}}, Nil{}}: KeyBool{flag}
    case Con{V.CVScalar{S.VString{text}}, Nil{}}: KeyString{text}
    case _: KeyInvalid{}

def bool_less(a: Bool, b: Bool) -> Bool:
  match a:
    case False{}:
      match b:
        case True{}: True{}
        case False{}: False{}
    case True{}: False{}

def key_less(left: SortKey, right: SortKey) -> Bool:
  match left:
    case KeyEmpty{}:
      match right:
        case KeyEmpty{}: False{}
        case KeyInvalid{}: False{}
        case _: True{}
    case KeyInt{a}:
      match right:
        case KeyInt{b}: Nat.is_lt(a, b)
        case _: False{}
    case KeyBool{a}:
      match right:
        case KeyBool{b}: bool_less(a, b)
        case _: False{}
    case KeyString{a}:
      match right:
        case KeyString{b}: String.is_lt(a, b)
        case _: False{}
    case KeyInvalid{}: False{}

# The comparison phase is explicit state, so fuel bounds each transition.
def insert_order(fuel: Nat, state: OrderState) -> List<&2, OrderEntry>:
  match fuel:
    case 0n:
      Nil{}
    case 1n+remaining:
      match state:
        case OrderInsert{+value, +key, sorted}:
          match sorted:
            case Nil{}: Con{OrderEntry{value, key}, Nil{}}
            case Con{OrderEntry{+head_value, +head_key}, tail}:
              before = key_less(key, head_key)
              insert_order(remaining, OrderCompare{before, value, key, head_value, head_key, tail})
        case OrderCompare{before, value, key, head_value, head_key, tail}:
          match before:
            case True{}: Con{OrderEntry{value, key}, Con{OrderEntry{head_value, head_key}, tail}}
            case False{}: Con{OrderEntry{head_value, head_key}, insert_order(remaining, OrderInsert{value, key, tail})}

def sort_entries(entries: List<&2, OrderEntry>, accumulated: List<&2, OrderEntry>) -> List<&2, OrderEntry>:
  match entries:
    case Nil{}: accumulated
    case Con{OrderEntry{value, key}, rest}: sort_entries(rest, insert_order(100000n, OrderInsert{value, key, accumulated}))

def ordered_values(entries: List<&2, OrderEntry>) -> List<&2, V.ComputedValue>:
  match entries:
    case Nil{}: Nil{}
    case Con{OrderEntry{value, key}, rest}: Con{value, ordered_values(rest)}

def update_store(current: M.Store, objects: List<&2, M.StoredObject>) -> M.Store:
  match current:
    case M.Store{old_objects, next_id}: M.Store{objects, next_id}

def insert_outcome(inserted: M.InsertResult) -> EvalOutcome:
  match inserted:
    case M.InsertResult{value, store}: EvalOK{EvalResult{Con{value, Nil{}}, store}}

def update_outcome(change: M.StoreChange, current: M.Store) -> EvalOutcome:
  match change:
    case M.StoreChange{objects, values, changed}:
      match changed:
        case True{}: EvalOK{EvalResult{values, update_store(current, objects)}}
        case False{}: EvalOK{EvalResult{Nil{}, current}}

def mutate(target: MutationTarget, fields: List<&2, V.StoredValue>, +current: M.Store) -> EvalOutcome:
  match target:
    case InsertTarget{object_type}: insert_outcome(M.store_insert(current, object_type, fields))
    case UpdateTarget{id}: update_outcome(M.store_update(current, id, fields), current)

def eval_machine(+schema: D.Schema, +initial: M.Store, fuel: Nat, state: Machine) -> EvalOutcome:
  match fuel:
    case 0n:
      EvalError{StepLimitExceeded{}}
    case 1n+remaining:
      match state:
        case Evaluate{current, +environment, expression, next}:
          match expression:
            case S.EVar{var}: eval_machine(schema, initial, remaining, Return{lookup_env(var, environment, current), next})
            case S.ELit{value}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{Con{V.CVScalar{value}, Nil{}}, current}}, next})
            case S.EEmpty{typ}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{Nil{}, current}}, next})
            case S.ETypeRoot{name}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{M.root_values(name, initial), current}}, next})
            case S.EUnion{left, right}: eval_machine(schema, initial, remaining, Evaluate{current, environment, left, KUnionLeft{right, environment, next}})
            case S.EProject{source, label}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KProject{label, next}})
            case S.EBacklink{source, label, owner}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KBacklink{label, owner, next}})
            case S.EField{label, value}: eval_machine(schema, initial, remaining, Evaluate{current, environment, value, next})
            case S.EShape{source, binder, fields}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KShapeSource{binder, fields, environment, next}})
            case S.ECall{builtin, args}:
              match args:
                case Con{first, Nil{}}: eval_machine(schema, initial, remaining, Evaluate{current, environment, first, KCallOne{builtin, next}})
                case Con{first, Con{second, Nil{}}}: eval_machine(schema, initial, remaining, Evaluate{current, environment, first, KCallLeft{builtin, second, environment, next}})
                case _: eval_machine(schema, initial, remaining, Raise{RuntimeCardinalityError{}, next})
            case S.EIfStrict{condition, when_true, when_false}: eval_machine(schema, initial, remaining, Evaluate{current, environment, condition, KIf{when_true, when_false, environment, next}})
            case S.EWith{bound, binder, body}: eval_machine(schema, initial, remaining, Evaluate{current, environment, bound, KWith{binder, body, environment, next}})
            case S.EFor{source, binder, body}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KForSource{binder, body, environment, next}})
            case S.EFilter{source, binder, condition}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KFilterSource{binder, condition, environment, next}})
            case S.EOrderBy{source, binder, key}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KOrderSource{binder, key, environment, next}})
            case S.EInsert{object_type, fields}: eval_machine(schema, initial, remaining, BuildMutation{InsertTarget{object_type}, fields, environment, current, Nil{}, next})
            case S.EUpdate{source, binder, fields}: eval_machine(schema, initial, remaining, Evaluate{current, environment, source, KUpdateSource{binder, fields, environment, next}})
        case Return{outcome, next}:
          match outcome:
            case EvalError{error}: eval_machine(schema, initial, remaining, Raise{error, next})
            case EvalOK{EvalResult{values, current}}:
              match next:
                case End{}: EvalOK{EvalResult{values, current}}
                case KUnionLeft{right, environment, later}: eval_machine(schema, initial, remaining, Evaluate{current, environment, right, KUnionRight{values, later}})
                case KUnionRight{left_values, later}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{V.append_values(left_values, values), current}}, later})
                case KProject{label, later}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{M.project_values(initial, label, values), current}}, later})
                case KBacklink{label, owner, later}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{M.backlink_from_values(initial, label, owner, values), current}}, later})
                case KIf{when_true, when_false, environment, later}: eval_machine(schema, initial, remaining, continue_if(current, values, when_true, when_false, environment, later))
                case KWith{binder, body, environment, later}: eval_machine(schema, initial, remaining, Evaluate{current, Con{ValueBinding{binder, values}, environment}, body, later})
                case KForSource{binder, body, environment, later}: eval_machine(schema, initial, remaining, RunFor{values, binder, body, environment, current, Nil{}, later})
                case KForBody{remaining_values, binder, body, environment, collected, later}: eval_machine(schema, initial, remaining, RunFor{remaining_values, binder, body, environment, current, V.append_values(collected, values), later})
                case KFilterSource{binder, condition, environment, later}: eval_machine(schema, initial, remaining, RunFilter{values, binder, condition, environment, current, Nil{}, later})
                case KFilterCondition{value, remaining_values, binder, condition, environment, collected, later}: eval_machine(schema, initial, remaining, continue_filter_condition(current, any_true(values), value, remaining_values, binder, condition, environment, collected, later))
                case KOrderSource{binder, key, environment, later}: eval_machine(schema, initial, remaining, RunOrder{values, binder, key, environment, current, Nil{}, later})
                case KOrderKey{value, remaining_values, binder, key, environment, collected, later}: eval_machine(schema, initial, remaining, continue_order_key(current, key_of(values), value, remaining_values, binder, key, environment, collected, later))
                case KShapeSource{binder, fields, environment, later}: eval_machine(schema, initial, remaining, RunShape{values, binder, fields, environment, current, Nil{}, later})
                case KShapeField{label, source, remaining_fields, source_tail, binder, all_fields, +environment, collected_fields, shaped, later}:
                  field = {V.CVField{label, V.Visible{}, values} : V.ComputedValue}
                  eval_machine(schema, initial, remaining, BuildShape{source, remaining_fields, source_tail, binder, all_fields, environment, current, V.append_values(collected_fields, Con{field, Nil{}}), shaped, later})
                case KCallOne{builtin, later}: eval_machine(schema, initial, remaining, Return{attach_store(builtin_one(builtin, values), current), later})
                case KCallLeft{builtin, second, environment, later}: eval_machine(schema, initial, remaining, Evaluate{current, environment, second, KCallRight{builtin, values, later}})
                case KCallRight{builtin, left_values, later}: eval_machine(schema, initial, remaining, Return{attach_store(builtin_two(builtin, left_values, values), current), later})
                case KUpdateSource{binder, fields, environment, later}: eval_machine(schema, initial, remaining, continue_update_source(current, values, binder, fields, environment, later))
                case KMutationField{target, label, remaining_fields, environment, collected, later}: eval_machine(schema, initial, remaining, continue_mutation_field(current, computed_values_to_stored(values), target, label, remaining_fields, environment, collected, later))
        case Raise{error, next}:
          eval_machine(schema, initial, remaining, continue_raise(error, continuation_tail(next)))
        case RunFor{remaining_values, +binder, +body, +environment, current, collected, next}:
          match remaining_values:
            case Nil{}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{collected, current}}, next})
            case Con{value, rest}: eval_machine(schema, initial, remaining, Evaluate{current, Con{ValueBinding{binder, Con{value, Nil{}}}, environment}, body, KForBody{rest, binder, body, environment, collected, next}})
        case RunFilter{remaining_values, +binder, +condition, +environment, current, collected, next}:
          match remaining_values:
            case Nil{}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{collected, current}}, next})
            case Con{+value, rest}: eval_machine(schema, initial, remaining, Evaluate{current, Con{ValueBinding{binder, Con{value, Nil{}}}, environment}, condition, KFilterCondition{value, rest, binder, condition, environment, collected, next}})
        case RunOrder{remaining_values, +binder, +key, +environment, current, collected, next}:
          match remaining_values:
            case Nil{}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{ordered_values(sort_entries(collected, Nil{})), current}}, next})
            case Con{+value, rest}: eval_machine(schema, initial, remaining, Evaluate{current, Con{ValueBinding{binder, Con{value, Nil{}}}, environment}, key, KOrderKey{value, rest, binder, key, environment, collected, next}})
        case RunShape{remaining_values, +binder, +fields, +environment, current, shaped, next}:
          match remaining_values:
            case Nil{}: eval_machine(schema, initial, remaining, Return{EvalOK{EvalResult{shaped, current}}, next})
            case Con{+source, source_tail}:
              match source:
                case V.CVObject{id, _}: eval_machine(schema, initial, remaining, BuildShape{source, fields, source_tail, binder, fields, Con{ValueBinding{binder, Con{source, Nil{}}}, environment}, current, Nil{}, shaped, next})
                case _: eval_machine(schema, initial, remaining, Raise{RuntimeTypeError{}, next})
        case BuildShape{source, remaining_fields, source_tail, binder, all_fields, +environment, current, collected_fields, shaped, next}:
          match remaining_fields:
            case Nil{}:
              eval_machine(schema, initial, remaining, continue_shape_value(current, shape_value(source, collected_fields), source_tail, binder, all_fields, environment, shaped, next))
            case Con{field_expression, rest}:
              eval_machine(schema, initial, remaining, continue_shape_field(current, split_field(field_expression), source, rest, source_tail, binder, all_fields, environment, collected_fields, shaped, next))
        case BuildMutation{target, remaining_fields, +environment, current, collected, next}:
          match remaining_fields:
            case Nil{}: eval_machine(schema, initial, remaining, Return{mutate(target, collected, current), next})
            case Con{field_expression, rest}:
              eval_machine(schema, initial, remaining, continue_mutation_expression(current, split_field(field_expression), target, rest, environment, collected, next))

def eval(+schema: D.Schema, +initial: M.Store, current: M.Store, +environment: List<&2, EvalEnv>, expression: S.Expr) -> EvalOutcome:
  eval_machine(schema, initial, 100000n, Evaluate{current, environment, expression, End{}})
