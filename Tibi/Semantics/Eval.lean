import Tibi.FinInt
import Tibi.Semantics.Env
import Tibi.Syntax

namespace Tibi

inductive EvalError
| OutOfBounds_Int64 (n : Int)

def EvalError.toString : EvalError → String
| .OutOfBounds_Int64 n => s!"{n} is out of Int64 bounds, should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"

instance : ToString EvalError where
  toString := EvalError.toString

inductive Eval : (Expr ctx ty) → Except EvalError ty.interp → Prop
| Const {n : Int} (hLt : n < Int64.size) (hGe : n >= -Int64.size)
  : Eval (.Const n) (.ok <| Int64.mk ⟨n, hLt, hGe⟩)
| ConstErr_lt {n : Int} (h : ¬ n < Int64.size)
  : Eval (.Const n) (.error <| .OutOfBounds_Int64 n)
| ConstErr_ge {n : Int} (h : ¬ n >= -Int64.size)
  : Eval (.Const n) (.error <| .OutOfBounds_Int64 n)
-- | Var' (env : Env (α :: .nil)) (a : α.interp) -- {x : Locals 0 (a :: ctx) a}
--   : Eval (.Var Locals.stop) (.ok <| a)
| Var (x : Locals k ctx ty) (env : Env ctx)
  : Eval (.Var x) (.ok <| env.lookup x)
| Lam (d : Eval e (.ok v))
  : Eval (.Lam e) (.ok <| fun _ => v)
| App (d₁ : Eval e₁ (.ok f)) (d₂ : Eval e₂ (.ok x))
  : Eval (.App e₁ e₂) (.ok <| f x)
