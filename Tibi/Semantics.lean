import Tibi.Basic
import Tibi.Interpreter

namespace Tibi

inductive Eval : Expr → Except EvalError (Fin 8) → Prop
| Const {n : Fin 8} : Eval (.Const n) (.ok n)
