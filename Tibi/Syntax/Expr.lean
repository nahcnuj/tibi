import Tibi.FinInt
import Tibi.Util

namespace Tibi

inductive Ty where
| int

@[reducible]
def Ty.interp : Ty → Type
| int => Int64

def Ty.toString : Ty → String
| int => "Int"

instance : ToString Ty where
  toString := Ty.toString

inductive Locals : Fin n → Tibi.Vec Ty n → Ty → Type where
| stop : Locals 0 (ty :: ctx) ty
| pop  : Locals k ctx ty → Locals k.succ (u :: ctx) ty

def Locals.idx : Locals n ctx ty → Fin n.succ
| stop  => Fin.mk 0 (Fin.succ_pos _)
| pop k => k.idx.succ

instance : ToString (Locals n ctx ty) where
  toString x := s!"${x.idx}"

inductive Expr : Vec Ty n → Ty → Type where
| Const : Int → Expr ctx .int
| Var   : Locals i ctx ty → Expr ctx ty

def Expr.toString : Expr ctx ty → String
| Const n => s!"<Const {n}>"
| Var x   => s!"<Var {x} @{ty}>"

instance : ToString (Expr ctx ty) where
  toString := Expr.toString
