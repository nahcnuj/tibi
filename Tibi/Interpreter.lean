import Tibi.Basic
import Tibi.FinInt

namespace Tibi

inductive EvalError

def Expr.eval : Expr → Except EvalError Int64
| .Const n => .ok <| Int64.ofFin n
