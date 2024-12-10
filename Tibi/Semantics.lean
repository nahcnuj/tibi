import Tibi.Basic
import Tibi.FinInt
import Tibi.Interpreter

namespace Tibi

inductive Eval : Expr → Except EvalError Int64 → Prop
| Const {n : Fin Int64.size} : Eval (.Const n) (.ok <| Int64.ofFin n)
