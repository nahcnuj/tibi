import Tibi.Wasm.Util.Nat

namespace Wasm

def String.encode (s : String) : List UInt8 :=
  let bs := s.toUTF8.toList
  Nat.encode bs.length ++ bs
