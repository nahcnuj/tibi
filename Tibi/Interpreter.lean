import Tibi.FinInt
import Tibi.Syntax
import Tibi.Semantics
import Tibi.Util

namespace Tibi

def Expr.eval (env : Env ctx) : {ty : Ty} → (e : Expr ctx ty) → ty.dom → {{ r | Eval e r }}
| _, .Const n, _ =>
    if h : (-Int64.size : Int) ≤ n ∧ n < Int64.size then
      .found (.ok <| Int64.mk ⟨n, h.right, h.left⟩) <| .Const h.right h.left
    else
      Decidable.not_and_iff_or_not_not.mp h |>.by_cases
        (fun h => .found (.error <| .OutOfBounds_Int64 n) <| Eval.ConstErr_ge h)
        (fun h => .found (.error <| .OutOfBounds_Int64 n) <| Eval.ConstErr_lt h)
| _, .Var x, _ =>
    .found (.ok <| env.lookup x) <| .Var x env
| _, .Lam e', x =>
    match e'.eval (x :: env) x with
    | .found (.ok v) h => .found (.ok <| fun _ => v) <| .Lam h
    | .unknown => .unknown
| .int, .App (dom := .int) (.Lam e₁) e₂, _ =>
    match e₂.eval env () with
    | .found (.ok v) h₂ =>
        match e₁.eval (v :: env) v with
        | .found (.ok v) h₁ =>
            .found (.ok <| v) <| .App h₁ h₂
        | _ => .unknown
    | _ => .unknown
| _, _, _ => .unknown
