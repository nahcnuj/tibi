import Tibi.Semantics
import Tibi.Typing

namespace Tibi

theorem HasType.det (h₁ : HasType e t₁) (h₂ : HasType e t₂) : t₁ = t₂ := by
  induction h₁ generalizing t₂ with
  | Int64 => cases h₂; rfl
  | Var => cases h₂; rfl
  | Lam _ ih => cases h₂ with | Lam h' => exact congrArg (Typ.Fn (.Var 0)) (ih h')
  | App _ _ ihf _ =>
      cases h₂ with
      | App hf' _ =>
          have h := ihf hf'
          simp only [Typ.Fn.injEq] at h
          exact h.2

theorem Expr.typeCheck_correct : (ht : HasType e t) → e.typeCheck = .found t ht
| .Int64 (n := n) hLt hGe =>
    have := eq_true <| And.intro (ge_iff_le.mp hGe) hLt
    dite_cond_eq_true this
| .Var => rfl
| .Lam h =>
    have ih := typeCheck_correct h
    simp only [Expr.typeCheck, ih]
| .App hf hv => by
    have ihf := typeCheck_correct hf
    have ihv := typeCheck_correct hv
    simp only [Expr.typeCheck, ihf, ihv]
    exact dif_pos rfl

theorem Expr.typeCheck_complete {e : Expr ctx ty}
: e.typeCheck = .unknown → ¬ HasType e t
:= fun h ht => by
    have := typeCheck_correct ht
    rw [h] at this
    exact Maybe.noConfusion this

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
| .Int64 hLt hGe, .Const ..      => ⟨_, rfl⟩
| .Int64 hLt _,   .ConstErr_lt h => absurd hLt h
| .Int64 _   hGe, .ConstErr_ge h => absurd hGe h
| .Var,           .Var ..        => ⟨_, rfl⟩
| .Lam _,         .Lam ..        => ⟨_, rfl⟩
| .App _ _,       .App ..        => ⟨_, rfl⟩
