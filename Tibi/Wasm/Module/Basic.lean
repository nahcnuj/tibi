import Tibi.Wasm.Basic
import Tibi.Wasm.Module.Component

namespace Wasm

/- # Module Sections -/

inductive Section : UInt8 → Type
| Types   (ts : Vec FuncType k) : Section  1
| Funcs   (ts : Vec Nat      k) : Section  3
| Exports (es : Vec Export   k) : Section  7
| Code    (cs : Vec Code     k) : Section 10

def Section.body : Section n → List UInt8
| Types   ts => ts.encode
| Funcs   ts => ts.encode
| Exports es => es.encode
| Code    cs => cs.encode

def Section.encode (s : Section n) : List UInt8 :=
  n
  :: s.body.length.encode
  ++ s.body

instance : Encode (Section n) where
  encode := Section.encode

end Wasm

section
open Wasm (Code Export FuncType Section)

/- ## Modules -/

def Wasm.magic : List UInt8 := [0x00, 0x61, 0x73, 0x6D]
def Wasm.version : List UInt8 := [0x01, 0x00, 0x00, 0x00]

-- TODO https://webassembly.github.io/spec/core/syntax/modules.html#syntax-module
structure Wasm where
  types : List FuncType
  funcs : List Nat
  codes : List Code
  exports : List Export

def Wasm.empty : Wasm := .mk [] [] [] []

def Wasm.build (w : Wasm) : ByteArray :=
  ByteArray.mk <| List.toArray <|
    Wasm.magic ++ Wasm.version
    ++ (Section.Types (Wasm.Vec.ofList w.types) |> Wasm.Encode.encode)
    ++ (Section.Funcs (Wasm.Vec.ofList w.funcs) |> Wasm.Encode.encode)
    ++ (Section.Exports (Wasm.Vec.ofList w.exports) |> Wasm.Encode.encode)
    ++ (Section.Code (Wasm.Vec.ofList w.codes) |> Wasm.Encode.encode)

end
