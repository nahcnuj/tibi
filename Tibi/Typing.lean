import Tibi.Basic
import Tibi.Syntax
import Tibi.Util

namespace Tibi

inductive Typ
| Int
deriving DecidableEq

def Typ.toString : Typ → String
| .Int => "Int"

instance : ToString Typ where
  toString := Typ.toString

inductive HasType : Expr → Typ → Prop
| Int {n : Int64} : HasType (.Const n) .Int

def Expr.typeCheck : (e : Expr) → {{ t | HasType e t }}
| .Const _ => .found .Int .Int
