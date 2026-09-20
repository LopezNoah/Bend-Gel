import Base
import ../Cardinality.bend as C
import ../src/Syntax.bend as S
import ../src/Schema.bend as D

def movie_name() -> S.TypeName:
  {S.TypeName{"Movie"} : S.TypeName}

def person_name() -> S.TypeName:
  {S.TypeName{"Person"} : S.TypeName}

def title_label() -> S.Label:
  {S.Label{"title"} : S.Label}

def movie_schema() -> D.Schema:
  movie_fields = {Con{S.SField{title_label(), S.SScalar{S.TString{}}, C.COne{}}, Nil{}} : List<&2, S.StoredType>}
  person_fields = {Con{S.SField{S.Label{"name"}, S.SScalar{S.TString{}}, C.COne{}}, Nil{}} : List<&2, S.StoredType>}
  movies = {D.ObjectSchema{movie_name(), movie_fields} : D.ObjectSchema}
  people = {D.ObjectSchema{person_name(), person_fields} : D.ObjectSchema}
  {D.Schema{Con{movies, Con{people, Nil{}}}} : D.Schema}

def main() -> Bool:
  schema = movie_schema()
  D.well_formed(schema)
