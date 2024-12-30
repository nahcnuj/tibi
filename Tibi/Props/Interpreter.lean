import Tibi.Semantics

namespace Tibi

theorem Expr.eval_correct
: ∀ e : Expr, Eval e e.eval
| .Const _ => .Const
