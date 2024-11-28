import Tibi.Basic
import Tibi.Wasm

namespace Tibi

private def compile' : Expr → List UInt8
| .Empty => []
| .Const n =>
  ((Wasm.Section.Types <| Wasm.Vec.ofList <|
        ⟨Wasm.Vec.nil, Wasm.Vec.ofList [Wasm.ValType.NumType .Int64]⟩
        :: .nil) |> Wasm.Encode.encode)
  ++ ((Wasm.Section.Funcs <| Wasm.Vec.ofList <|
        0
        :: .nil) |> Wasm.Encode.encode)
  ++ ((Wasm.Section.Exports <| Wasm.Vec.ofList <|
        ⟨"main", .Func 0⟩
        :: .nil) |> Wasm.Encode.encode)
  ++ ((Wasm.Section.Code <| Wasm.Vec.ofList <|
        ⟨[], [.i64__const n]⟩
        :: .nil) |> Wasm.Encode.encode)

def compile (e : Expr) : ByteArray :=
  ByteArray.mk <| List.toArray <|
    Wasm.magic ++ Wasm.version ++ compile' e
