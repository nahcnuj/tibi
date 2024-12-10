import Tibi.Basic
import Tibi.Util

namespace Tibi

inductive HasType : Expr → Typ → Prop
| Nat {n : Fin Int64.size} : HasType (.Const n) .Nat

def Expr.typeCheck : (e : Expr) → {{ t | HasType e t }}
| .Const _ => .found .Nat .Nat
