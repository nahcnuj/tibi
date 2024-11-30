import Tibi.Basic
import Tibi.Wasm

namespace Tibi

def Expr.compile : Expr → List Wasm.Instr
| .Empty => []
| .Const n => [.i64__const n]
