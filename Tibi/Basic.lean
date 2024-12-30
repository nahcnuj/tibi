import Tibi.FinInt

namespace Tibi

inductive Token
| Numeral (n : Nat)
deriving BEq

instance : ToString Token where
  toString
  | .Numeral n => s!"<Numeral {n}>"

class RuntimeError (ε : Type _) [ToString ε] where

@[default_instance]
instance [ToString ε] : RuntimeError ε where
