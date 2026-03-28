import Tibi.Wasm.Basic
import Tibi.Wasm.Encoder
import Tibi.Wasm.Value

namespace Wasm

open Wasm.Value

/- # Wasm Instructions -/

inductive Instr
-- Numeric Instructions
| i32.const (i : Int32)
| i64.const (i : Int64)
-- Variable Instructions
| local.get (i : Nat)

def Instr.encode : Instr → List UInt8
| i32.const i => 0x41 :: i.encode
| i64.const i => 0x42 :: i.encode
| local.get i => 0x42 :: (Encoder.encode 128) ++ 0x21 :: Encoder.encode i ++ 0x20 :: Encoder.encode i

instance : Encoder Instr where
  encode := Instr.encode
