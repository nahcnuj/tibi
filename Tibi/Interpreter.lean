import Tibi.Basic
import Tibi.FinInt
import Tibi.Syntax
import Tibi.Semantics

namespace Tibi

def Expr.eval : Expr → Except EvalError Int64
| .Const n =>
    if h : (-Int64.size : Int) ≤ n ∧ n < Int64.size then
      .ok <| Int64.mk ⟨n, h.right, h.left⟩
    else
      .error <| .OutOfBounds_Int64 n
