import Tibi.Basic
import Tibi.FinInt
import Tibi.Interpreter

namespace Tibi

inductive Eval : Expr → Except EvalError Int64 → Prop
| Const {n : Int64} : Eval (.Const n) (.ok n)
