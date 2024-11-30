namespace Wasm

def Nat.encode (n : Nat) : List UInt8 :=
  if n < 2 ^ 7 then
    [n.toUInt8]
  else
    let x := (n &&& 0x7F) + 0x80
    x.toUInt8 :: Nat.encode (n >>> 7)

#guard Nat.encode 0 == [0]
#guard Nat.encode 1 == [1]
#guard Nat.encode 127 == [0x7F]
#guard Nat.encode 128 == [0x80, 0x01]
#guard Nat.encode 12857 == [0xB9, 0x64]
