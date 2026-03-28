import Tibi.Semantics
import Tibi.Typing

namespace Tibi

theorem HasType.det : HasType e t₁ → HasType e t₂ → t₁ = t₂
| .Int64 ..,  .Int64 ..    => rfl
| .Var,       .Var         => rfl
| .Lam h,     .Lam h'      => by rw [h.det h']
| .App h₁ h₂, .App h₁' h₂' => h₂.det h₂' ▸ h₁.det h₁' |> Typ.Fn.inj |>.right

/--
Reference: [A Certified Type Checker \- Lean Documentation Overview](https://lean-lang.org/lean4/doc/examples/tc.lean.html)
-/
theorem Expr.typeCheck_correct {e : Expr ctx ty}
  (ht : HasType e t)
  (h : e.typeCheck ≠ .unknown)
: e.typeCheck = .found t ht
:= by
  revert h
  match e.typeCheck with
  | .found ty' h₁' => intro ; have := ht.det h₁' ; subst this ; rfl
  | .unknown       => intros; contradiction
/-
Try this: (match e.typeCheck with
  | Maybe.found ty' h₁' => fun h =>
    let_fun this := HasType.det ht h₁';
    Eq.ndrec (motive := fun ty' =>
      ∀ (h₁' : HasType e ty'), Maybe.found ty' h₁' ≠ Maybe.unknown → Maybe.found ty' h₁' = Maybe.found t ht)
      (fun h₁' h => Eq.refl (Maybe.found t h₁')) this h₁' h
  | Maybe.unknown => fun h => absurd (Eq.refl Maybe.unknown) h)
  h
-/

-- TODO prove Expr.typeCheck_complete
/-
theorem Expr.typeCheck_complete {e : Expr ctx ty}
: e.typeCheck = .unknown → ¬HasType e t
:= by
  induction e with simp [Expr.typeCheck]
  | Const n =>
      intro h ht
      match ht with
      | .Int64 hLt hGe =>
          have := h hGe hLt
          contradiction
  | Lam e ih =>
      match h : e.typeCheck with
      | .found t' ht' => intro ; contradiction
      | .unknown =>
          have : ¬HasType e t := ih h
          intro _ ht'
          match ht' with
          | .Lam h' =>
              sorry
  | App e₁ e₂ ih₁ ih₂ => sorry
-/

-- TODO prove : Decidable (HasType e t)
/-
instance (e : Expr ctx ty) (t : Typ) : Decidable (HasType e t) :=
  match h : e.typeCheck with
  | .found t' ht' =>
      if heq : t = t' then
        isTrue (heq ▸ ht')
      else
        isFalse fun ht => heq (HasType.det ht ht')
  | .unknown => isFalse (Expr.typeCheck_complete h)
-/

-- TODO prove type_safe
/-
theorem type_safe {e : Expr ctx ty}
: HasType e t → Eval e r → ∃ v, r = .ok v
| .Int64 hLt hGe, .Const ..      => ⟨Int64.mk ⟨_, hLt, hGe⟩, rfl⟩
| .Int64 hLt _,   .ConstErr_lt h => absurd hLt h
| .Int64 _   hGe, .ConstErr_ge h => absurd hGe h
| .Var,           .Var x => ⟨env.lookup x, rfl⟩
-/
