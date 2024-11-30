namespace Tibi

inductive Token
| Numeral (n : Nat)
deriving BEq

instance : ToString Token where
  toString
  | .Numeral n => s!"<Numeral {n}>"

inductive Expr
| Const : Fin 8 → Expr

instance : ToString Expr where
  toString
  | .Const n => s!"<Const {n}>"

inductive Typ
| Nat
deriving DecidableEq
