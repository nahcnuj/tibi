import Tibi.Basic
import Tibi.Syntax
import Tibi.Wasm

namespace Tibi

open Wasm.Value

def Expr.compile : Expr → List Wasm.Instr
| .Const n => [.i64__const n]
