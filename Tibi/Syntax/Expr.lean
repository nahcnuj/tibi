import Tibi.FinInt

namespace Tibi

inductive Expr
| Const : Int → Expr

instance : ToString Expr where
  toString
  | .Const n => s!"<Const {n}>"
