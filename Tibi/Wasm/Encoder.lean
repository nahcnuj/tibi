import Tibi.Wasm.Util
import Tibi.Wasm.Value

namespace Wasm

/- # Wasm Binary Encoder -/

/--
`Encoder` type class supports encoding to Wasm binary, a list of bytes.
-/
class Encoder (α : Type) where
  encode : α → List UInt8

instance : Encoder Nat where
  encode := Nat.encode

instance : Encoder (Fin n) where
  encode := Nat.encode ∘ Fin.val

instance : Encoder UInt8 where
  encode n := [n]

instance : Encoder String where
  encode := String.encode

open Wasm.Value

instance : Encoder Int32 where
  encode := Int32.encode

instance : Encoder Int64 where
  encode := Int64.encode
