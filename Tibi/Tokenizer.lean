import Tibi.Basic
import Tibi.Tokenizer.Basic

namespace Tibi

inductive Err
| Unconsumed (rest : String)

instance : ToString Err where
  toString
  | .Unconsumed rest => s!"\"{rest}\" was not consumed by the tokenizer"

private def tokenizer (s : String) : Except Err (Token × String) :=
  match digits s with
  | .some (t, rest) => .ok (t, rest)
  | .none => .error <| .Unconsumed s

private def tokenizeRest (tokens : List Token) (s : String) : Except Err (List Token) :=
  if s.isEmpty then .ok tokens
  else
    tokenizer s >>= fun (t, rest) =>
      if rest.length < s.length then
        tokenizeRest (tokens.concat t) rest
      else
        .error <| .Unconsumed rest
termination_by s.length

def tokenize : String → Except Err (List Token) := tokenizeRest []
