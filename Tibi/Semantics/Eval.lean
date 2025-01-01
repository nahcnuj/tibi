import Tibi.FinInt
import Tibi.Semantics.Env
import Tibi.Syntax

namespace Tibi

inductive EvalError
| OutOfBounds_Int64 (n : Int)

inductive Eval (env : Env ctx) : (Expr ctx ty) → Except EvalError Int64 → Prop
| Const {n : Int} (hLt : n < Int64.size) (hGe : n >= -Int64.size)
  : Eval env (.Const n) (.ok <| Int64.mk ⟨n, hLt, hGe⟩)
| ConstErr_lt {n : Int} (h : ¬ n < Int64.size)
  : Eval env (.Const n) (.error <| .OutOfBounds_Int64 n)
| ConstErr_ge {n : Int} (h : ¬ n >= -Int64.size)
  : Eval env (.Const n) (.error <| .OutOfBounds_Int64 n)
| Var (x : Locals i ctx ty)
  : Eval env (.Var x) (.ok (env.lookup x))

def EvalError.toString : EvalError → String
| .OutOfBounds_Int64 n => s!"{n} is out of Int64 bounds, should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"

instance : ToString EvalError where
  toString := EvalError.toString
