namespace Tibi

inductive Token
| Numeral (n : Nat)
deriving BEq

instance : ToString Token where
  toString
  | .Numeral n => s!"<Numeral {n}>"
