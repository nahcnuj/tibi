import Tibi.Basic
import Tibi.Wasm

namespace Tibi

open Wasm.Value

def Expr.compile : Expr → List Wasm.Instr
| .Const n => [.i64__const <| Int64.ofFin n]
