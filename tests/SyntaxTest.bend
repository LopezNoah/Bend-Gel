import Base
import ../src/Syntax.bend as S

def main() -> Bool:
  a = {S.Label{"title"} : S.Label}
  b = {S.Label{"title"} : S.Label}
  S.label_eq(a, b)
