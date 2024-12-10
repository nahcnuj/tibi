import Tibi.FinInt

namespace Wasm.Value

open Tibi (FinInt)

abbrev Int32 := Tibi.Int32
abbrev Int64 := Tibi.Int64

private def Int.ofNat.encode (n : Nat) : List UInt8 :=
  let b : UInt8 := n.toUInt8 &&& 0x7F
  if n < 2 ^ 6 then
    [b]
  else
    (0x80 ||| b) :: Int.ofNat.encode (n >>> 7)

#guard Int.ofNat.encode 0 == [0x00]
#guard Int.ofNat.encode 2 == [0x02]
#guard Int.ofNat.encode 63 == [0x3F]
#guard Int.ofNat.encode 64 == [0xC0, 0x00]
#guard Int.ofNat.encode 65 == [0xC1, 0x00]
#guard Int.ofNat.encode 127 == [0xFF, 0x00]
#guard Int.ofNat.encode 128 == [0x80, 0x01]
#guard Int.ofNat.encode 129 == [0x81, 0x01]
#guard Int.ofNat.encode 9223372036854775807 == [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00]

private def Int.negSucc.encode (n : Nat) : List UInt8 :=
  let b : UInt8 := n.toUInt8.complement &&& 0x7F
  if n < 2 ^ 6 then
    [b]
  else
    (0x80 ||| b) :: Int.negSucc.encode (n >>> 7)

#guard Int.negSucc.encode 0 == [0x7F] -- -1
#guard Int.negSucc.encode 1 == [0x7E] -- -2
#guard Int.negSucc.encode 63 == [0x40] -- -64
#guard Int.negSucc.encode 64 == [0xBF, 0x7F] -- -65
#guard Int.negSucc.encode 65 == [0xBE, 0x7F] -- -66
#guard Int.negSucc.encode 126 == [0x81, 0x7F] -- -127
#guard Int.negSucc.encode 127 == [0x80, 0x7F] -- -128
#guard Int.negSucc.encode 128 == [0xFF, 0x7E] -- -129
#guard Int.negSucc.encode 9223372036854775807 == [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x7F] -- -9223372036854775808

/--
`FinInt.encode` encodes a `FinInt m` value into a binary sequence of LEB128 format.
-/
def FinInt.encode (i : FinInt m) : List UInt8 :=
  match i.val with
  | .ofNat   n => Int.ofNat.encode n
  | .negSucc n => Int.negSucc.encode n

def Int32.encode : Int32 → List UInt8 := FinInt.encode ∘ Tibi.Int32.val

def Int64.encode : Int64 → List UInt8 := FinInt.encode ∘ Tibi.Int64.val
