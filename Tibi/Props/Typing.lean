import Tibi.Semantics
import Tibi.Typing

namespace Tibi

-- theorem HasType.det (h₁ : HasType e t₁) (h₂ : HasType e t₂) : t₁ = t₂ := by
--   cases h₁ <;> cases h₂ <;> rfl

/-
theorem Expr.typeCheck_correct {e : Expr ctx ty}
: (ht : HasType e t) → e.typeCheck = .found ty.toTyp ht
| .Int64 (n := n) hLt hGe =>
    have := eq_true <| And.intro (ge_iff_le.mp hGe) hLt
    dite_cond_eq_true this
| .Var => rfl

theorem Expr.typeCheck_complete {e : Expr ctx ty}
: e.typeCheck = .unknown → ¬ HasType e ty.toTyp
:= by
  dsimp [Expr.typeCheck]
  intro h (ht : HasType env e ty.toTyp)
  match ht with
  | .Int64 hLt hGe =>
      simp at h
      exact h hGe hLt

instance (e : Expr ctx ty) (t : Typ) : Decidable (HasType e t) :=
  match h : e.typeCheck with
  | .found t' ht' =>
      if heq : t = t' then
        isTrue (heq ▸ ht')
      else
        isFalse fun ht => heq (HasType.det ht ht')
  | .unknown => isFalse (Expr.typeCheck_complete h)

theorem type_safe {e : Expr ctx ty}
: HasType e t → Eval e r → ∃ v, r = .ok v
| .Int64 hLt hGe, .Const ..      => ⟨Int64.mk ⟨_, hLt, hGe⟩, rfl⟩
| .Int64 hLt _,   .ConstErr_lt h => absurd hLt h
| .Int64 _   hGe, .ConstErr_ge h => absurd hGe h
| .Var,           .Var x => ⟨env.lookup x, rfl⟩
-/
