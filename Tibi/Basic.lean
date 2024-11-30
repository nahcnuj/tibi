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

class RuntimeError (ε : Type _) [ToString ε] where

@[default_instance]
instance [ToString ε] : RuntimeError ε where
