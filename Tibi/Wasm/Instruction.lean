import Tibi.Wasm.Basic

namespace Wasm

/- # Wasm Instructions -/

inductive Instr
-- Numeric Instructions
| i32__const (i : Int) -- FIXME accept i32
| i64__const (i : Int) -- FIXME accept i64

instance : Encode Instr where
  encode
    | .i32__const i => 0x41 :: i.toNat.encode -- FIXME integer encoding
    | .i64__const i => 0x42 :: i.toNat.encode -- FIXME integer encoding
