import Tibi.FinInt
import Tibi.Util

namespace Tibi

inductive Ty where
| int
| fn (a b : Ty)

@[reducible]
def Ty.interp : Ty → Type
| int     => Int64
| fn a b  => a.interp → b.interp

@[reducible]
def Ty.dom : Ty → Type
| int     => Unit
| fn a _  => a.interp

def Ty.toString : Ty → String
| int     => "Int"
| fn a b  => s!"{a.toString} -> {b.toString}"

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
| Lam   : Expr (dom :: ctx) ran → Expr ctx (.fn dom ran)
| App   : Expr ctx (.fn dom ran) → Expr ctx dom → Expr ctx ran

def Expr.toString : Expr ctx ty → String
| Const n => s!"<Const {n}>"
| Var x   => s!"<Var {x} @{ty}>"
| Lam e   => s!"<Lam {e.toString}>"
| App e₁ e₂ => s!"<App {e₁.toString} {e₂.toString}>"

instance : ToString (Expr ctx ty) where
  toString := Expr.toString
