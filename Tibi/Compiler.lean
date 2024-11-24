import Tibi.Wasm

namespace Tibi

def compile : ByteArray :=
  ByteArray.mk <| List.toArray <|
    Wasm.magic ++ Wasm.version
    ++ ((Wasm.Section.Types <| Wasm.Vec.ofList <|
          ⟨Wasm.Vec.nil, Wasm.Vec.ofList [Wasm.ValType.NumType .Int64]⟩
          :: .nil) |> Wasm.Encode.encode)
    ++ ((Wasm.Section.Funcs <| Wasm.Vec.ofList <|
          0
          :: .nil) |> Wasm.Encode.encode)
    ++ ((Wasm.Section.Exports <| Wasm.Vec.ofList <|
          ⟨"main", .Func 0⟩
          :: .nil) |> Wasm.Encode.encode)
    ++ ((Wasm.Section.Code <| Wasm.Vec.ofList <|
          ⟨[], [0x42, 0x01]⟩
          :: .nil) |> Wasm.Encode.encode)
