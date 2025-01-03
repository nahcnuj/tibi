import Tibi.FinInt
import Tibi.Semantics
import Tibi.Syntax
import Tibi.Util

namespace Tibi

inductive Typ
| Var (idx : Nat)
| Int64
| Fn (a : Typ) (b : Typ)
deriving DecidableEq

def Typ.toString : Typ → String
| Var idx => s!"α{idx}"
| Int64   => "Int"
| Fn a b  => s!"{a.toString} -> {b.toString}"

instance : ToString Typ where
  toString := Typ.toString

def Ty.toTyp : Ty → Typ
| int     => .Int64
| fn a b  => .Fn a.toTyp b.toTyp
| cls _ b => b.toTyp

inductive HasType : Expr ctx ty → Typ → Prop
| Int64 {n : Int} (hLt : n < Int64.size) (hGe : n ≥ -Int64.size) : HasType (.Const n) .Int64
| Var {x : Locals i ctx ty} : HasType (.Var x) (Ty.cls ty ty).toTyp
| Lam (h : HasType e t) : HasType (.Lam e) (.Fn .Int64/-(.Var 0)-/ t)
| App (hf : HasType f (.Fn dom ran)) (hv : HasType v dom) : HasType (.App f v) ran

def Expr.typeCheck : (e : Expr ctx ty) → {{ t | HasType e t }}
| .Const n =>
    if h : -Int64.size ≤ n ∧ n < Int64.size then
      .found .Int64 <| .Int64 h.right h.left
    else
      .unknown
| .Var _ =>
    .found _ .Var
| .Lam e =>
    match e.typeCheck with
    | .found t h => .found (.Fn .Int64/-(.Var 0)-/ t) <| .Lam h
    | .unknown   => .unknown
| .App f v =>
    match f.typeCheck, v.typeCheck with
    | .found (.Fn a b) hf, .found a' hv =>
        if h : a = a' then
          .found b <| .App hf (h ▸ hv)
        else
          .unknown
    | _, _ => .unknown
-- | _ => .unknown
