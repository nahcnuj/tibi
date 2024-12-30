import Tibi.Basic
import Tibi.FinInt
import Tibi.Syntax

namespace Tibi

inductive EvalError

instance : ToString EvalError where
  toString _ := "something went wrong"

def Expr.eval : Expr → Except EvalError Int64
| .Const n => .ok <| Int64.ofFin n
