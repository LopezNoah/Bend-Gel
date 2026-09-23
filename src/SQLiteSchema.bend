import Base
import ../Cardinality.bend as C
import ./Syntax.bend as S
import ./Schema.bend as D
import ./EdgeQLSchema.bend as EdgeSchema

type DDLResult is Data:
  DDLReady{statements: List<&2, String>}
  DDLFailed{}

type FieldDDL is Data:
  Column{sql: String}
  Junction{sql: String}
  BadField{}

type FieldsDDL is Data:
  FieldsReady{columns: List<&2, String>, junctions: List<&2, String>}
  FieldsFailed{}

type FieldsState is Data:
  ScanFields{fields: List<&2, S.StoredType>, owner: String, columns: List<&2, String>, junctions: List<&2, String>}
  NextField{result: FieldDDL, fields: List<&2, S.StoredType>, owner: String, columns: List<&2, String>, junctions: List<&2, String>}

type TablesState is Data:
  ScanTables{objects: List<&2, D.ObjectSchema>, statements: List<&2, String>}
  NextTable{result: FieldsDDL, name: String, objects: List<&2, D.ObjectSchema>, statements: List<&2, String>}

# SQLite double-quoted identifiers, including identifiers supplied directly
# through Schema rather than via the EdgeQL lexer.
def escape_char(head: Char, escaped: String) -> String:
  match head:
    case '"': SCon{head, SCon{head, escaped}}
    case _: SCon{head, escaped}

def escape_identifier(text: String) -> String:
  match text:
    case SNil{}: SNil{}
    case SCon{+head, tail}:
      escape_char(head, escape_identifier(tail))

def quote(text: String) -> String:
  String.concat(["\"", escape_identifier(text), "\""])

def scalar_column_type(scalar: S.ScalarType) -> String:
  match scalar:
    case S.TInt{}: "INTEGER"
    case S.TBool{}: "INTEGER"
    case S.TString{}: "TEXT"

def junction_name(owner: String, label: String) -> String:
  String.concat([owner, ".", label])

def bool_check(scalar: S.ScalarType, label: String) -> String:
  match scalar:
    case S.TBool{}: String.concat([" CHECK (", quote(label), " IN (0, 1))"])
    case _: ""

def scalar_column(+label: String, +scalar: S.ScalarType, nullability: String) -> String:
  String.concat([quote(label), " ", scalar_column_type(scalar), nullability, bool_check(scalar, label)])

def scalar_junction(+owner: String, label: String, +scalar: S.ScalarType) -> String:
  name = junction_name(owner, label)
  String.concat(["CREATE TABLE ", quote(name), " (\"source_id\" INTEGER NOT NULL REFERENCES ", quote(owner),
    "(\"id\") ON DELETE CASCADE, \"value\" ", scalar_column_type(scalar),
    " NOT NULL", bool_check(scalar, "value"), ", PRIMARY KEY (\"source_id\", \"value\"))"])

def link_junction(+owner: String, label: String, target: String) -> String:
  name = junction_name(owner, label)
  String.concat(["CREATE TABLE ", quote(name), " (\"source_id\" INTEGER NOT NULL REFERENCES ", quote(owner),
    "(\"id\") ON DELETE CASCADE, \"target_id\" INTEGER NOT NULL REFERENCES ", quote(target),
    "(\"id\"), PRIMARY KEY (\"source_id\", \"target_id\"))"])

def scalar_field(card: C.Card, owner: String, label: String, scalar: S.ScalarType) -> FieldDDL:
  match card:
    case C.CEmpty{}: BadField{}
    case C.COptional{}: Column{scalar_column(label, scalar, "")}
    case C.COne{}: Column{scalar_column(label, scalar, " NOT NULL")}
    case C.CMany{}: Junction{scalar_junction(owner, label, scalar)}
    case C.CNonEmptyMany{}: Junction{scalar_junction(owner, label, scalar)}

def link_card(card: C.Card, owner: String, label: String, text: String) -> FieldDDL:
  match card:
    case C.CEmpty{}: BadField{}
    case C.COptional{}: Column{String.concat([quote(label), " INTEGER REFERENCES ", quote(text), "(\"id\")"])}
    case C.COne{}: Column{String.concat([quote(label), " INTEGER NOT NULL REFERENCES ", quote(text), "(\"id\")"])}
    case C.CMany{}: Junction{link_junction(owner, label, text)}
    case C.CNonEmptyMany{}: Junction{link_junction(owner, label, text)}

def link_field_empty(card: C.Card, owner: String, label: String, target: S.TypeName) -> FieldDDL:
  match target:
    case S.TypeName{text}: link_card(card, owner, label, text)

def link_field(card: C.Card, owner: String, label: String, target: S.TypeName, properties: List<&2, S.StoredType>) -> FieldDDL:
  match properties:
    case Nil{}: link_field_empty(card, owner, label, target)
    # Link properties need a junction with additional payload columns; do not
    # silently discard them while this subset is being implemented.
    case _: BadField{}

def field_sql(field: S.StoredType, owner: String) -> FieldDDL:
  match field:
    case S.SField{S.Label{label}, typ, card}:
      match typ:
        case S.SScalar{scalar}: scalar_field(card, owner, label, scalar)
        case S.SLink{target, properties}: link_field(card, owner, label, target, properties)
        case S.SField{inner, inner_type, inner_card}: BadField{}
    case _: BadField{}

def fields_go(fuel: Nat, state: FieldsState) -> FieldsDDL:
  match fuel:
    case 0n: FieldsFailed{}
    case 1n+remaining:
      match state:
        case ScanFields{fields, +owner, columns, junctions}:
          match fields:
            case Nil{}: FieldsReady{List.reverse(&2, String, columns), List.reverse(&2, String, junctions)}
            case Con{field, rest}: fields_go(remaining, NextField{field_sql(field, owner), rest, owner, columns, junctions})
        case NextField{result, fields, owner, columns, junctions}:
          match result:
            case BadField{}: FieldsFailed{}
            case Column{sql}: fields_go(remaining, ScanFields{fields, owner, Con{sql, columns}, junctions})
            case Junction{sql}: fields_go(remaining, ScanFields{fields, owner, columns, Con{sql, junctions}})

def table_sql(name: String, columns: List<&2, String>) -> String:
  String.concat(["CREATE TABLE ", quote(name), " (", String.join(Con{"\"id\" INTEGER PRIMARY KEY", columns}, ", "), ")"])

def tables_go(fuel: Nat, state: TablesState) -> DDLResult:
  match fuel:
    case 0n: DDLFailed{}
    case 1n+remaining:
      match state:
        case ScanTables{objects, statements}:
          match objects:
            case Nil{}: DDLReady{List.reverse(&2, String, statements)}
            case Con{D.ObjectSchema{S.TypeName{+name}, fields}, rest}:
              tables_go(remaining, NextTable{fields_go(100000n, ScanFields{fields, name, Nil{}, Nil{}}), name, rest, statements})
        case NextTable{result, name, objects, statements}:
          match result:
            case FieldsFailed{}: DDLFailed{}
            case FieldsReady{columns, junctions}:
              # Junction DDL follows the owning table, before the next object.
              next = List.reverse(&2, String, Con{table_sql(name, columns), junctions})
              tables_go(remaining, ScanTables{objects, List.append(&2, String, next, statements)})

def valid_name(+name: String) -> Bool:
  Bool.and(Bool.not(String.is_empty(name)), Bool.not(String.contains(name, ".")))

def field_has_name(+name: String, fields: List<&2, S.StoredType>) -> Bool:
  match fields:
    case Nil{}: False{}
    case Con{field, rest}:
      match field:
        case S.SField{S.Label{label}, typ, card}:
          Bool.or(String.eq(String.to_lower(name), String.to_lower(label)), field_has_name(name, rest))
        case _: False{}

def valid_fields(fields: List<&2, S.StoredType>) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{field, +rest}:
      match field:
        case S.SField{S.Label{+label}, typ, card}:
          Bool.and(valid_name(label), Bool.and(Bool.not(String.eq(String.to_lower(label), "id")),
            Bool.and(Bool.not(field_has_name(label, rest)), valid_fields(rest))))
        case _: False{}

def object_has_name(+name: String, objects: List<&2, D.ObjectSchema>) -> Bool:
  match objects:
    case Nil{}: False{}
    case Con{D.ObjectSchema{S.TypeName{other}, fields}, rest}:
      Bool.or(String.eq(String.to_lower(name), String.to_lower(other)), object_has_name(name, rest))

def valid_objects(objects: List<&2, D.ObjectSchema>) -> Bool:
  match objects:
    case Nil{}: True{}
    case Con{D.ObjectSchema{S.TypeName{+name}, fields}, +rest}:
      Bool.and(valid_name(name), Bool.and(Bool.not(object_has_name(name, rest)),
        Bool.and(valid_fields(fields), valid_objects(rest))))

def compile_valid(valid: Bool, objects: List<&2, D.ObjectSchema>) -> DDLResult:
  match valid:
    case True{}: tables_go(100000n, ScanTables{objects, Nil{}})
    case False{}: DDLFailed{}

def compile(schema: D.Schema) -> DDLResult:
  match schema:
    case D.Schema{+objects}:
      compile_valid(Bool.and(D.well_formed(D.Schema{objects}), valid_objects(objects)), objects)

def compile_source_result(result: EdgeSchema.SchemaResult) -> DDLResult:
  match result:
    case EdgeSchema.SchemaParsed{schema}: compile(schema)
    case EdgeSchema.SchemaFailed{}: DDLFailed{}

def from_source(source: String) -> DDLResult:
  compile_source_result(EdgeSchema.from_source(source))
