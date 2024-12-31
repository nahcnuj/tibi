import Tibi.Semantics
import Tibi.Typing

namespace Tibi

theorem HasType.det (h₁ : HasType e t₁) (h₂ : HasType e t₂) : t₁ = t₂ := by
  cases h₁ <;> cases h₂ <;> rfl

theorem Expr.typeCheck_correct {e : Expr}
: (ht : HasType e ty) → e.typeCheck = .found ty ht
| .Int64 (n := n) hLt hGe =>
    have := eq_true <| And.intro (ge_iff_le.mp hGe) hLt
    dite_cond_eq_true this

theorem Expr.typeCheck_complete {e : Expr}
: e.typeCheck = .unknown → ¬ HasType e ty
:= by
  dsimp [Expr.typeCheck]
  intro h (ht : HasType e ty)
  match ht with
  | .Int64 hLt hGe =>
      have := eq_true <| And.intro (ge_iff_le.mp hGe) hLt
      have := h ▸ dite_cond_eq_true this
      exact Maybe.noConfusion this

instance (e : Expr) (t : Typ) : Decidable (HasType e t) :=
  match h : e.typeCheck with
  | .found t' ht' =>
      if heq : t = t' then
        isTrue (heq ▸ ht')
      else
        isFalse fun ht => heq (HasType.det ht ht')
  | .unknown => isFalse (Expr.typeCheck_complete h)

theorem type_safe {e : Expr}
: HasType e t → Eval e r → ∃ v, r = .ok v
| .Int64 hLt hGe, .Const ..      => ⟨Int64.mk ⟨_, hLt, hGe⟩, rfl⟩
| .Int64 hLt _,   .ConstErr_lt h => absurd hLt h
| .Int64 _   hGe, .ConstErr_ge h => absurd hGe h
