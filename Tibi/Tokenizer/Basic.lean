import Tibi.Basic

namespace Tibi.Tokenizer

def digits (s : String) : Option (Nat × String) :=
  let ds := s.takeWhile Char.isDigit
  if ds.length > 0 then
    .some (ds.toNat!, s.drop ds.length)
  else
    .none

#guard digits "" == .none
#guard digits "abc" == .none
#guard digits "1" == .some (1, "")
#guard digits "123" == .some (123, "")
#guard digits "012" == .some (12, "")
#guard digits "1abc" == .some (1, "abc")
#guard digits "1.0" == .some (1, ".0")

def choice {T : Type u} : List (String → Option (T × String)) → String → Option (T × String)
  | []      => fun _ => .none
  | p :: ps => fun s => p s <|> choice ps s
