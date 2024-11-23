import Tibi.Basic
import Tibi.Combinator

namespace Tibi.Tokenizer

inductive Err
| Unconsumed (rest : String)

instance : ToString Err where
  toString
  | .Unconsumed rest => s!"\"{rest}\" was not consumed"

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

def skipSpaces (next : String → α) : String → α :=
  next ∘ String.trimLeft

section

private def transform (f : α → Token) : α × β → Option (Token × β) :=
  Option.some ∘ Prod.map f id

instance : HAndThen (String → Option (α × β)) (α → Token) (String → Option (Token × β)) where
  hAndThen attempt f := fun s => attempt s >>= transform (f ())

private def tokenizer : String → Option (Token × String) :=
  choice <| [
    skipSpaces digits >> Token.Numeral,
  ]

end

private def tokenizeRest (tokens : List Token) (s : String) : Except Err (List Token) :=
  if s.trimLeft.isEmpty then .ok tokens
  else
    if let some (t, rest) := tokenizer s then
      if rest.length < s.length then
        tokenizeRest (tokens.concat t) rest
      else
        .error <| .Unconsumed rest
    else
      .error <| .Unconsumed s
termination_by s.length

def tokenize : String → Except Err (List Token) := tokenizeRest []
