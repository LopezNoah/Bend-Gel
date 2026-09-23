import Base
import ../src/EdgeQLPretty.bend as Q
import ../src/EdgeQLParser.bend as P
import ../src/EdgeQLSource.bend as Source
import ../src/EdgeQLSyntax.bend as E

# Exercise the textual spelling through the real lexer as well as the
# token-level law checked by PROOF.bend.
def matches_source(ast: Q.CanonicalExpr, result: P.ParseResult) -> Bool:
  match ast result:
    case Q.Atomic{Q.One{}} P.Parsed{E.SLiteral{E.LInt{1n}}}: True{}
    case Q.Atomic{Q.Two{}} P.Parsed{E.SLiteral{E.LInt{2n}}}: True{}
    case Q.Addition{Q.One{}} P.Parsed{E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{1n}}}}: True{}
    case Q.Addition{Q.Two{}} P.Parsed{E.SAdd{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}}: True{}
    case Q.Call{Q.One{}} P.Parsed{E.SCall{E.Name{"add"}, Con{E.SLiteral{E.LInt{1n}}, Con{E.SLiteral{E.LInt{1n}}, Nil{}}}}}: True{}
    case Q.Call{Q.Two{}} P.Parsed{E.SCall{E.Name{"add"}, Con{E.SLiteral{E.LInt{1n}}, Con{E.SLiteral{E.LInt{2n}}, Nil{}}}}}: True{}
    case Q.GroupedUnionAdd{Q.One{}} P.Parsed{E.SAdd{E.SUnion{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{1n}}}}: True{}
    case Q.GroupedUnionAdd{Q.Two{}} P.Parsed{E.SAdd{E.SUnion{E.SLiteral{E.LInt{1n}}, E.SLiteral{E.LInt{2n}}}, E.SLiteral{E.LInt{2n}}}}: True{}
    case _ _: False{}

def check_result(ok: Bool) -> IO(Unit):
  match ok:
    case True{}: IO.pure(Unit, Unit{})
    case False{}: IO.die(Unit, 1, "canonical source spelling failed to roundtrip")

def check(+ast: Q.CanonicalExpr) -> IO(Unit):
  check_result(matches_source(ast, Source.parse_source(Q.source(ast))))

def main() -> IO(Unit):
  do IO<Unit>:
    check(Q.Atomic{Q.One{}})
    check(Q.Atomic{Q.Two{}})
    check(Q.Addition{Q.One{}})
    check(Q.Addition{Q.Two{}})
    check(Q.Call{Q.One{}})
    check(Q.Call{Q.Two{}})
    check(Q.GroupedUnionAdd{Q.One{}})
    check(Q.GroupedUnionAdd{Q.Two{}})
