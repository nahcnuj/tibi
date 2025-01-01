import Tibi.FinInt
import Tibi.Semantics
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

def Ty.toTyp : Ty → Typ
| int => .Int64

inductive HasType (env : Env ctx) : Expr ctx ty → Typ → Prop
| Int64 {n : Int} (hLt : n < Int64.size) (hGe : n ≥ -Int64.size) : HasType env (.Const n) .Int64
| Var {x : Locals i ctx ty} : HasType env (.Var x) ty.toTyp

def Expr.typeCheck (env : Env ctx) : (e : Expr ctx ty) → {{ t | HasType env e t }}
| .Const n =>
    if h : -Int64.size ≤ n ∧ n < Int64.size then
      .found .Int64 <| .Int64 h.right h.left
    else
      .unknown
| .Var _ =>
      .found ty.toTyp .Var
