import Tibi.Basic
import Tibi.FinInt
import Tibi.Syntax

namespace Tibi

inductive EvalError
| OutOfBounds_Int64 (n : Int)

inductive Eval : Expr → Except EvalError Int64 → Prop
| Const       {n : Int} (hLt : n < Int64.size) (hGe : n >= -Int64.size) : Eval (.Const n) (.ok <| Int64.mk ⟨n, hLt, hGe⟩)
| ConstErr_lt {n : Int} (h : ¬ n < Int64.size)   : Eval (.Const n) (.error <| .OutOfBounds_Int64 n)
| ConstErr_ge {n : Int} (h : ¬ n >= -Int64.size) : Eval (.Const n) (.error <| .OutOfBounds_Int64 n)

def EvalError.toString : EvalError → String
| .OutOfBounds_Int64 n => s!"{n} is out of Int64 bounds, should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"

instance : ToString EvalError where
  toString := EvalError.toString
