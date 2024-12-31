import Tibi.Basic
import Tibi.FinInt
import Tibi.Syntax
import Tibi.Semantics
import Tibi.Util

namespace Tibi

def Expr.eval : (e : Expr) → {{ r | Eval e r }}
| .Const n =>
    if h : (-Int64.size : Int) ≤ n ∧ n < Int64.size then
      .found (.ok <| Int64.mk ⟨n, h.right, h.left⟩) <| Eval.Const h.right h.left
    else
      Decidable.not_and_iff_or_not_not.mp h |>.by_cases
        (fun h => .found (.error <| .OutOfBounds_Int64 n) <| Eval.ConstErr_ge h)
        (fun h => .found (.error <| .OutOfBounds_Int64 n) <| Eval.ConstErr_lt h)
