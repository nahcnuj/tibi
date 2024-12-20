import Tibi.Basic

namespace Tibi

inductive ParseError
| Err (s : String)
| Unimplemented -- XXX

instance : ToString ParseError where
  toString
    | .Err s => s
    | .Unimplemented => "Unimplemented"

def parse : Token → List Token → Except ParseError (Expr × List Token)
| .Numeral n, ts =>
    if h : n < 8 then
      .ok (.Const ⟨n, h⟩, ts)
    else
      .error <| .Err s!"violate n < 8: n = {n}"
