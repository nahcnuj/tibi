import Tibi.Basic
import Tibi.ParserT
import Tibi.Syntax

namespace Tibi

inductive ParseError
| Err (s : String)
| Unimplemented -- XXX

instance : ToString ParseError where
  toString
    | .Err s => s
    | .Unimplemented => "Unimplemented"

def parse : Token → List Token → Except ParseError (Expr × List Token)
| .Numeral n, ts =>
    if h : n < 2^63 then
      .ok (.Const ⟨n, h⟩, ts)
    else
      .error <| .Err s!"violate n < 2⁶³: n = {n}"

namespace v2

inductive Parser.Error
| ExpectedDigit (got : Char)
| ExpectedNonZeroDigit (got : Char)
| IOError (e : IO.Error)
| Unconsumed (rest : String)

def Parser.Error.toString : Parser.Error → String
| ExpectedDigit got        => s!"Expected a digit, got '{got}'"
| ExpectedNonZeroDigit got => s!"Expected a non-zero digit, got '{got}'"
| IOError e                => s!"IO Error: {e}"
| Unconsumed rest          => s!"\"{rest}\" was not consumed"

instance : ToString Parser.Error where
  toString := Parser.Error.toString

abbrev Parser := ParserT Char Parser.Error Id

private def digit : Parser Nat :=
  ParserT.satisfy Char.isDigit .ExpectedDigit
  |>.map (fun c => c.toNat - '0'.toNat)

private def nonZeroDigit : Parser Nat :=
  ParserT.diff digit (ParserT.char '0') .ExpectedNonZeroDigit

private def digits : Parser (List Nat) :=
  ParserT.repeatGreedily digit

def decimal : Parser Nat :=
  (
    ParserT.char '0'
      |>.map fun _ => 0
  )
  <|> (
    nonZeroDigit >> digits
      |>.map fun (n, ns) => ns.concat n |>.foldr (fun n s => s * 10 + n) 0
  )

private def parser : ExceptT String Parser Expr :=
  (
    decimal
      |>.map fun n =>
        if h : n < Int64.size then
          .ok (.Const ⟨n, h⟩)
        else
          .error s!"Numeric literal `n` should be satisfied that 0 ≤ n < 2{Nat.toSuperscriptString 63}"
  )

-- abbrev parse (s : String) := parser s.data

-- #eval parse ""
-- #eval parse "0"
-- #eval parse "1230"
-- #eval parse "0120"
-- #eval parse "-1"
-- #eval parse "9223372036854775808"

partial def parse' : (ReaderT (IO String) (ExceptT String Parser)) Expr := do
  fun getLine cs =>
    match parser cs with
    | .error .UnexpectedEndOfInput => do
        match getLine () with
        | .ok s _    => parse' getLine <| cs.append s.data
        | .error e _ => Except.error <| Parser.Error.IOError e
    | v => v

#eval parse' (pure "0120") "123".data
#eval parse' (pure "-1") "".data
#eval parse' (pure "9223372036854775808") "".data
#eval parse' (pure "9223372036854775808") "".data
#eval parse' (pure "0120") "123".data

def parse (stream : IO.FS.Stream) :=
  stream.getLine >>= fun s =>
    match s.data with
    | [] => pure Option.none
    | cs => pure <| Option.some <| parse' stream.getLine cs

def parseLine (line : String) :=
  match line.trimRight.data with
  | [] => Option.none
  | cs => Option.some <| parse' (pure "") cs
