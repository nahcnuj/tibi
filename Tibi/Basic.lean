namespace Tibi

inductive Token
| Numeral (n : Nat)
deriving BEq

instance : ToString Token where
  toString
  | .Numeral n => s!"<Numeral {n}>"

inductive Expr
| Empty
| Const : Fin 8 → Expr

instance : ToString Expr where
  toString
  | .Empty   => "<Empty>"
  | .Const n => s!"<Const {n}>"

inductive Typ
| Nat
deriving DecidableEq
