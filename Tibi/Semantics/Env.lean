import Tibi.Syntax
import Tibi.Util

namespace Tibi

inductive Env : Vec Ty n → Type where
| nil  : Env Vec.nil
| cons : Ty.interp a → Env ctx → Env (a :: ctx)

infix:67 " :: " => Env.cons

def Env.lookup : Locals i ctx ty → Env ctx → (Ty.cls ty ty).interp
| .stop,  x :: _  => x
| .pop k, _ :: xs => xs.lookup k
