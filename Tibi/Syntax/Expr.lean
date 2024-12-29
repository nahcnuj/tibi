import Tibi.FinInt

namespace Tibi.Syntax

inductive Expr
| Const : Fin Int64.size → Expr

instance : ToString Expr where
  toString
  | .Const n => s!"<Const {n}>"
