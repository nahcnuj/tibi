import Tibi.FinInt
import Tibi.Syntax
import Tibi.Util

namespace Tibi

inductive Typ
| Int64
deriving DecidableEq

def Typ.toString : Typ → String
| Int64 => "Int"

instance : ToString Typ where
  toString := Typ.toString

inductive HasType : Expr → Typ → Prop
| Int64 {n : Int} (hLt : n < Int64.size) (hGe : n ≥ -Int64.size) : HasType (.Const n) .Int64

def Expr.typeCheck : (e : Expr) → {{ t | HasType e t }}
| .Const n =>
    if h : -Int64.size ≤ n ∧ n < Int64.size then
      .found .Int64 <| .Int64 h.right h.left
    else
      .unknown
