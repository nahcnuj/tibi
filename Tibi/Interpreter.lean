import Tibi.Basic

namespace Tibi

inductive EvalError

def Expr.eval : Expr → Except EvalError (Fin 8)
| .Const n => .ok n
