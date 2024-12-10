namespace Wasm

/--
`Nat.encode` encodes a Nat value, i.e. an unsigned integer, into a binary sequence of LEB128 format.
-/
def Nat.encode (n : Nat) : List UInt8 :=
  let b : UInt8 := n.toUInt8 &&& 0x7F
  if n < 2 ^ 7 then
    [b]
  else
    (0x80 ||| b) :: Nat.encode (n >>> 7)

#guard Nat.encode 0 == [0]
#guard Nat.encode 1 == [1]
#guard Nat.encode 127 == [0x7F]
#guard Nat.encode 128 == [0x80, 0x01]
#guard Nat.encode 12857 == [0xB9, 0x64]
