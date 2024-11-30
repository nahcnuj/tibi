import Tibi.Typing

namespace Tibi

theorem HasType.det (h₁ : HasType e t₁) (h₂ : HasType e t₂) : t₁ = t₂ := by
  cases h₁ <;> cases h₂ <;> rfl

theorem Expr.typeCheck_correct {e : Expr}
  (ht : HasType e ty)
  (hr : e.typeCheck ≠ .unknown)
: e.typeCheck = .found ty ht
:=
  match hr' : e.typeCheck with
  | .found _ ht' => HasType.det ht ht' ▸ rfl
  | .unknown     => absurd hr' hr

theorem Expr.typeCheck_complete {e : Expr} : e.typeCheck = .unknown → ¬ HasType e ty := by
  simp [Expr.typeCheck]
  -- induction e with simp [Expr.typeCheck]
  -- | _ => sorry

instance (e : Expr) (t : Typ) : Decidable (HasType e t) :=
  match h : e.typeCheck with
  | .found t' ht' =>
      if heq : t = t' then
        isTrue (heq ▸ ht')
      else
        isFalse fun ht => heq (HasType.det ht ht')
  | .unknown => isFalse (Expr.typeCheck_complete h)
