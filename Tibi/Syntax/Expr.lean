import Tibi.FinInt

namespace Tibi

inductive Expr
| Const : Fin Int64.size → Expr

instance : ToString Expr where
  toString
  | .Const n => s!"<Const {n}>"
