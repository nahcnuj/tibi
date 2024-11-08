import Tibi.Basic
import Tibi.Tokenizer.Basic

namespace Tibi

inductive Err
| Unconsumed (rest : String)

instance : ToString Err where
  toString
  | .Unconsumed rest => s!"\"{rest}\" was not consumed"

private def transform (f : α → Token) : α × β → Option (Token × β) :=
  Option.some ∘ Prod.map f id

instance : HAndThen (String → Option (α × β)) (α → Token) (String → Option (Token × β)) where
  hAndThen attempt f := fun s => attempt s >>= transform (f ())

private def tokenizer : String → Option (Token × String) :=
  choice <| [
    digits >> Token.Numeral,
  ]

private def tokenizeRest (tokens : List Token) (s : String) : Except Err (List Token) :=
  if s.isEmpty then .ok tokens
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
