import Tibi.Wasm.Basic
import Tibi.Wasm.Instruction
import Tibi.Wasm.Util

namespace Wasm

/- # Module Components -/

/- ## Exports -/

inductive ExportDesc
| Func (idx : Nat)

def ExportDesc.encode : ExportDesc → List UInt8
| Func idx => [0x00] ++ idx.encode

structure Export where
  name : String
  desc : ExportDesc

def Export.encode : Export → List UInt8
| ⟨name, desc⟩ => name.encode ++ desc.encode

instance : Encode Export where
  encode := Export.encode

/- ## Code -/

structure Code where
  locals : List (Nat × ValType)
  expr   : List Instr

instance : Encode (Nat × ValType) where
  encode
  | ⟨n, t⟩ => n.encode ++ t.encode

def Code.func : Code → List UInt8
| ⟨locals, expr⟩ => (Vec.ofList locals).encode ++ List.join (expr.map Encode.encode) ++ [0x0B]

def Code.encode (c : Code) : List UInt8 :=
  c.func.length.encode ++ c.func

instance : Encode Code where
  encode := Code.encode
