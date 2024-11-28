import Tibi.Basic
import Tibi.Wasm

namespace Tibi

private def compile' : Expr → Wasm
| .Empty => Wasm.empty
| .Const n =>
    Wasm.mk
      [⟨[], [Wasm.ValType.NumType .Int64]⟩]
      [0]
      [⟨[], [.i64__const n]⟩]
      [⟨"main", .Func 0⟩]

def compile (e : Expr) : ByteArray :=
  Wasm.build <| compile' e
