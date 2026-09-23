import Base
import ../Cardinality.bend as C
import ./Syntax.bend as S
import ./Schema.bend as D
import ./EdgeQLToken.bend as T
import ./EdgeQLSyntax.bend as E
import ./EdgeQLParser.bend as P
import ./EdgeQLSource.bend as Source

# Parse only the small SDL/DDL subset represented by the core StoredType.
# Schema statements remain token-backed in EdgeQLParser; this module is the
# explicit schema-to-core boundary. Unknown syntax fails closed.
type SchemaResult is Data:
  SchemaParsed{schema: D.Schema}
  SchemaFailed{}

type FieldsResult is Data:
  FieldsParsed{fields: List<&2, S.StoredType>, rest: List<&2, T.Token>}
  FieldsFailed{}

type ObjectResult is Data:
  ObjectParsed{object: D.ObjectSchema, rest: List<&2, T.Token>}
  ObjectFailed{}

type ObjectsResult is Data:
  ObjectsParsed{objects: List<&2, D.ObjectSchema>, rest: List<&2, T.Token>}
  ObjectsFailed{}

type FieldResult is Data:
  FieldParsed{field: S.StoredType, rest: List<&2, T.Token>}
  FieldFailed{}

type FieldsState is Data:
  ScanFields{tokens: List<&2, T.Token>, accumulated: List<&2, S.StoredType>}
  NextField{result: FieldResult, accumulated: List<&2, S.StoredType>}

type ObjectsState is Data:
  ScanObjects{tokens: List<&2, T.Token>, accumulated: List<&2, D.ObjectSchema>}
  NextObject{result: ObjectResult, accumulated: List<&2, D.ObjectSchema>}

type CollectState is Data:
  Collect{statements: List<&2, E.SurfaceStatement>, objects: List<&2, D.ObjectSchema>}
  Append{result: Maybe<&2, List<&2, D.ObjectSchema>>, rest: List<&2, E.SurfaceStatement>, objects: List<&2, D.ObjectSchema>}

def cardinality(required: Bool, multi: Bool) -> C.Card:
  match required multi:
    case True{} True{}: C.CNonEmptyMany{}
    case True{} False{}: C.COne{}
    case False{} True{}: C.CMany{}
    case False{} False{}: C.COptional{}

def scalar_type(text: String) -> Maybe<&2, S.ScalarType>:
  match text:
    case "str": Some{S.TString{}}
    case "int64": Some{S.TInt{}}
    case "bool": Some{S.TBool{}}
    case _: None{}

def property_type(result: Maybe<&2, S.ScalarType>, label: String, card: C.Card, rest: List<&2, T.Token>) -> FieldResult:
  match result:
    case Some{scalar}: FieldParsed{S.SField{S.Label{label}, S.SScalar{scalar}, card}, rest}
    case None{}: FieldFailed{}

def field_target_kind(kind: String, label: String, card: C.Card, target: String, rest: List<&2, T.Token>) -> FieldResult:
  match kind:
    case "property": property_type(scalar_type(target), label, card, rest)
    case "link": FieldParsed{S.SField{S.Label{label}, S.SLink{S.TypeName{target}, Nil{}}, card}, rest}
    case _: FieldFailed{}

def field_target(kind: String, label: String, card: C.Card, tokens: List<&2, T.Token>) -> FieldResult:
  match tokens:
    case Con{T.TOther{'-'}, Con{T.TOther{'>'}, Con{T.TIdentifier{target}, Con{T.TSemicolon{}, rest}}}}:
      field_target_kind(kind, label, card, target, rest)
    case _: FieldFailed{}

def field_kind(required: Bool, multi: Bool, tokens: List<&2, T.Token>) -> FieldResult:
  match tokens:
    case Con{T.TIdentifier{kind}, Con{T.TIdentifier{label}, rest}}:
      field_target(kind, label, cardinality(required, multi), rest)
    case _: FieldFailed{}

def field_qualifier(tokens: List<&2, T.Token>) -> FieldResult:
  match tokens:
    case Con{T.TIdentifier{"required"}, Con{T.TIdentifier{"multi"}, rest}}:
      field_kind(True{}, True{}, rest)
    case Con{T.TIdentifier{"multi"}, Con{T.TIdentifier{"required"}, rest}}:
      field_kind(True{}, True{}, rest)
    case Con{T.TIdentifier{"required"}, rest}: field_kind(True{}, False{}, rest)
    case Con{T.TIdentifier{"multi"}, rest}: field_kind(False{}, True{}, rest)
    case _: field_kind(False{}, False{}, tokens)

def parse_field(tokens: List<&2, T.Token>) -> FieldResult:
  match tokens:
    case Con{T.TIdentifier{"create"}, rest}: field_qualifier(rest)
    case _: field_qualifier(tokens)

def parse_fields_go(fuel: Nat, state: FieldsState) -> FieldsResult:
  match fuel:
    case 0n: FieldsFailed{}
    case 1n+remaining:
      match state:
        case ScanFields{tokens, accumulated}:
          match tokens:
            case Con{T.TRBrace{}, rest}: FieldsParsed{List.reverse(&2, S.StoredType, accumulated), rest}
            case _: parse_fields_go(remaining, NextField{parse_field(tokens), accumulated})
        case NextField{result, accumulated}:
          match result:
            case FieldFailed{}: FieldsFailed{}
            case FieldParsed{field, rest}: parse_fields_go(remaining, ScanFields{rest, Con{field, accumulated}})

def parse_fields(tokens: List<&2, T.Token>) -> FieldsResult:
  parse_fields_go(100000n, ScanFields{tokens, Nil{}})

def object_fields(name: String, result: FieldsResult) -> ObjectResult:
  match result:
    case FieldsFailed{}: ObjectFailed{}
    case FieldsParsed{fields, rest}: ObjectParsed{D.ObjectSchema{S.TypeName{name}, fields}, rest}

def parse_object(tokens: List<&2, T.Token>) -> ObjectResult:
  match tokens:
    case Con{T.TIdentifier{"create"}, rest}: parse_object(rest)
    case Con{T.TIdentifier{"type"}, Con{T.TIdentifier{name}, Con{T.TLBrace{}, rest}}}:
      object_fields(name, parse_fields(rest))
    case _: ObjectFailed{}

def parse_objects_go(fuel: Nat, state: ObjectsState) -> ObjectsResult:
  match fuel:
    case 0n: ObjectsFailed{}
    case 1n+remaining:
      match state:
        case ScanObjects{tokens, accumulated}:
          match tokens:
            case Con{T.TRBrace{}, rest}: ObjectsParsed{List.reverse(&2, D.ObjectSchema, accumulated), rest}
            case _: parse_objects_go(remaining, NextObject{parse_object(tokens), accumulated})
        case NextObject{result, accumulated}:
          match result:
            case ObjectFailed{}: ObjectsFailed{}
            case ObjectParsed{object, rest}: parse_objects_go(remaining, ScanObjects{rest, Con{object, accumulated}})

def parse_objects(tokens: List<&2, T.Token>) -> ObjectsResult:
  parse_objects_go(100000n, ScanObjects{tokens, Nil{}})

def end_statement(tokens: List<&2, T.Token>) -> Bool:
  match tokens:
    case Nil{}: True{}
    case Con{T.TSemicolon{}, Nil{}}: True{}
    case _: False{}

def schema_objects_end(ended: Bool, objects: List<&2, D.ObjectSchema>) -> Maybe<&2, List<&2, D.ObjectSchema>>:
  match ended:
    case True{}: Some{objects}
    case False{}: None{}

def schema_objects(result: ObjectsResult) -> Maybe<&2, List<&2, D.ObjectSchema>>:
  match result:
    case ObjectsFailed{}: None{}
    case ObjectsParsed{objects, rest}:
      schema_objects_end(end_statement(rest), objects)

def one_object_end(ended: Bool, object: D.ObjectSchema) -> Maybe<&2, List<&2, D.ObjectSchema>>:
  match ended:
    case True{}: Some{Con{object, Nil{}}}
    case False{}: None{}

def one_object(result: ObjectResult) -> Maybe<&2, List<&2, D.ObjectSchema>>:
  match result:
    case ObjectFailed{}: None{}
    case ObjectParsed{object, rest}:
      one_object_end(end_statement(rest), object)

def parse_schema_tokens(tokens: List<&2, T.Token>) -> Maybe<&2, List<&2, D.ObjectSchema>>:
  match tokens:
    case Con{T.TIdentifier{"module"}, Con{T.TIdentifier{"default"}, Con{T.TLBrace{}, rest}}}:
      schema_objects(parse_objects(rest))
    case _: one_object(parse_object(tokens))

def checked_schema(valid: Bool, schema: D.Schema) -> SchemaResult:
  match valid:
    case True{}: SchemaParsed{schema}
    case False{}: SchemaFailed{}

def collect_go(fuel: Nat, state: CollectState) -> SchemaResult:
  match fuel:
    case 0n: SchemaFailed{}
    case 1n+remaining:
      match state:
        case Collect{statements, +objects}:
          match statements:
            case Nil{}:
              checked_schema(D.well_formed(D.Schema{objects}), D.Schema{objects})
            case Con{statement, rest}:
              match statement:
                case E.SSchema{tokens}: collect_go(remaining, Append{parse_schema_tokens(tokens), rest, objects})
                case E.SQuery{value}: collect_go(remaining, Collect{rest, objects})
                case E.SUnparsed{tokens}: SchemaFailed{}
        case Append{result, rest, objects}:
          match result:
            case None{}: SchemaFailed{}
            case Some{more}: collect_go(remaining, Collect{rest, List.append(&2, D.ObjectSchema, objects, more)})

def from_document(document: E.SurfaceDocument) -> SchemaResult:
  match document:
    case E.Document{statements}: collect_go(100000n, Collect{statements, Nil{}})

def from_document_result(result: P.DocumentResult) -> SchemaResult:
  match result:
    case P.DocumentParsed{document}: from_document(document)
    case P.DocumentFailed{error}: SchemaFailed{}

def from_source(source: String) -> SchemaResult:
  from_document_result(Source.parse_document_source(source))
