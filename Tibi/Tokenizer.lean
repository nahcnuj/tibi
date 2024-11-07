import Tibi.Basic

namespace Tibi

inductive Err
| Unconsumed (rest : String)

instance : ToString Err where
  toString
  | .Unconsumed rest => s!"\"{rest}\" was not consumed by the tokenizer"

def f : String → Except Err (Token × String)
  | s => .ok (.T s.front, s.drop 1)

private def tokenizeRest (tokens : List Token) (s : String) : Except Err (List Token) :=
  if s.isEmpty then .ok tokens
  else
    f s >>= fun (t, rest) =>
      if rest.length < s.length then
        tokenizeRest (tokens.concat t) rest
      else
        .error <| .Unconsumed rest
termination_by s.length

def tokenize : String → Except Err (List Token) := tokenizeRest []
