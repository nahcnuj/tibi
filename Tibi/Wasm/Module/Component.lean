import Tibi.Wasm.Basic
import Tibi.Wasm.Encoder
import Tibi.Wasm.Instruction
import Tibi.Wasm.Util

namespace Wasm

/- # Module Components -/

/- ## Exports -/

inductive ExportDesc
| Func (idx : Nat)

def ExportDesc.encode : ExportDesc → List UInt8
| Func idx => 0x00 :: Nat.encode idx

structure Export where
  name : String
  desc : ExportDesc

def Export.encode : Export → List UInt8
| ⟨name, desc⟩ => Encoder.encode name ++ desc.encode

instance : Encoder Export where
  encode := Export.encode

/- ## Code -/

structure Code where
  locals : List (Nat × ValType)
  expr   : List Instr

instance : Encoder (Nat × ValType) where
  encode
  | ⟨n, t⟩ => Nat.encode n ++ t.encode

def Code.func : Code → List UInt8
| ⟨locals, expr⟩ => (Vec.ofList locals).encode ++ List.flatten (expr.map Encoder.encode) ++ [0x0B]

def Code.encode (c : Code) : List UInt8 :=
  Nat.encode c.func.length ++ c.func

instance : Encoder Code where
  encode := Code.encode
