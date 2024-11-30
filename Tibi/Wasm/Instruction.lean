import Tibi.Wasm.Basic
import Tibi.Wasm.Encoder

namespace Wasm

/- # Wasm Instructions -/

inductive Instr
-- Numeric Instructions
| i32__const (i : Int) -- FIXME accept i32
| i64__const (i : Int) -- FIXME accept i64

instance : Encoder Instr where
  encode
    | .i32__const i => 0x41 :: Nat.encode i.toNat -- FIXME integer encoding
    | .i64__const i => 0x42 :: Nat.encode i.toNat -- FIXME integer encoding
