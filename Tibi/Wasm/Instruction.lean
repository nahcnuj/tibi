import Tibi.Wasm.Basic
import Tibi.Wasm.Encoder
import Tibi.Wasm.Value

namespace Wasm

open Wasm.Value

/- # Wasm Instructions -/

inductive Instr
-- Numeric Instructions
| i32__const (i : Int32)
| i64__const (i : Int64)

instance : Encoder Instr where
  encode
    | .i32__const i => 0x41 :: i.encode
    | .i64__const i => 0x42 :: i.encode
