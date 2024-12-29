import Tibi.Basic
import Tibi.Combinator
import Tibi.Parser
import Tibi.Util

namespace Tibi

inductive TokenizeError
| ExpectedChar (want got : Char)
| ExpectedEndOfInput (rest : String)
| SomethingWentWrong (rest : String)
| Unconsumed (rest : String)
| UnexpectedEndOfInput

def TokenizeError.toString : TokenizeError → String
| ExpectedChar want got => s!"Expected '{want}', got '{got}'"
| ExpectedEndOfInput rest => s!"Expected the end of input, got \"{rest}\""
| SomethingWentWrong rest => s!"Something went wrong during tokenizing the rest of input: \"{rest}\""
| Unconsumed rest => s!"\"{rest}\" was not consumed"
| UnexpectedEndOfInput => s!"Unexpected the end of input"

instance : ToString TokenizeError where
  toString := TokenizeError.toString

instance : MonadLift (ExceptT TokenizeError Id) IO where
  monadLift := ExceptT.liftIO

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

private def tokenizeRest (tokens : List Token) (s : String) : Except TokenizeError (List Token) :=
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

def tokenize : String → ExceptT TokenizeError Id (List Token) := tokenizeRest []


namespace v2

abbrev Tokenizer := ParserT Char TokenizeError Id

-- instance : Monad Tokenizer := inferInstanceAs <| Monad (ParserT Char TokenizeError Id)

namespace Tokenizer

-- def anyChar : Tokenizer Char
-- | []      => throw <| .UserError TokenizeError.UnexpectedEndOfInput
-- | c :: cs => ParserT.anyChar c cs

-- def eof : Tokenizer Unit
-- | [] => pure ((), [])
-- | cs => throw <| .UserError <| .ExpectedEndOfInput <| String.mk cs

-- def satisfy (cond : Char → Bool) : Tokenizer Char :=
--   ParserT.satisfy cond <| .SomethingWentWrong ""
-- #check (ParserT.satisfy (· == 'a') : TokenizeError → Tokenizer Char)
  -- >>= fun c cs =>
  --   if cond c then
  --     pure (c, cs)
  --   else
  --     throw <| .UserError <| .SomethingWentWrong <| String.mk <| c :: cs

-- def char (ch : Char) : Tokenizer Char :=
--   anyChar
--   >>= fun c cs =>
--     if c == ch then
--       pure (ch, cs)
--     else
--       throw <| .UserError <| .ExpectedChar ch c

end Tokenizer

open Tokenizer -- in
def tokenizer : Tokenizer Char := anyChar

def tokenize (s : String) := tokenizer s.data

#eval tokenize ""
#eval tokenize "abc"
#eval tokenize "a"

-- #eval eof "".data
-- #eval eof "abc".data
-- #eval eof "a".data

def parse' : Tokenizer Char := anyChar
#eval parse' "".data
#eval parse' "abc".data
#eval parse' "a".data
#eval parse' "A".data
#eval match parse' "".data with
  | .ok _ => "Ok"
  | .error _ => "Error"

-- def parsea := char 'a'
-- #eval parsea "".data
-- #eval parsea "abc".data
-- #eval parsea "a".data
-- #eval parsea "A".data

def parseb : Tokenizer Char := satisfy (· == 'b') (TokenizeError.ExpectedChar 'b')
#eval parseb "".data -- .data "".data
#eval parseb "bcd".data
#eval parseb "b".data
#eval parseb "B".data





end v2
