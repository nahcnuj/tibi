import Tibi.Basic

def digits (s : String) : Option (Token × String) :=
  let ds := s.takeWhile Char.isDigit
  if ds.length > 0 then
    .some (.Numeral ds.toNat!, s.drop ds.length)
  else
    .none

#guard digits "" == .none
#guard digits "abc" == .none
#guard digits "1" == .some (.Numeral 1, "")
#guard digits "123" == .some (.Numeral 123, "")
#guard digits "012" == .some (.Numeral 12, "")
#guard digits "1abc" == .some (.Numeral 1, "abc")
#guard digits "1.0" == .some (.Numeral 1, ".0")
