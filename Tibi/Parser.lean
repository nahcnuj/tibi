import Tibi.Basic
import Tibi.ParserT
import Tibi.Syntax

namespace Tibi

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

private def natNumber : Parser Nat :=
  (
    ParserT.char '0'
      |>.map fun _ => 0
  )
  <|> (
    nonZeroDigit >> digits
      |>.map fun (n, ns) => ns.concat n |>.foldr (fun n s => s * 10 + n) 0
  )

private def sign : Parser (Nat → Int) :=
      ( ParserT.char '+' |>.map fun _ => Int.ofNat )
  <|> ( ParserT.char '-' |>.map fun _ => Int.negSucc ∘ Nat.pred )

private def intNumber : Parser Int :=
  (
    sign >> natNumber
      |>.map fun (sgn, n) =>
        match n with
        | 0 => 0
        | _ => sgn n
  )

private def parser : ExceptT String Parser Expr :=
  (
    natNumber
      |>.map fun n =>
        if h : n < Int64.size then
          .ok <| .Const <| Int64.ofFin ⟨n, h⟩
        else
          .error s!"Numeric literal `n` should be satisfied that 0 ≤ n < 2{Nat.toSuperscriptString 63}"
  )
  <|> (
    intNumber
      |>.map fun n =>
        if h : -(Int64.size : Int) <= n ∧ n < Int64.size then
          .ok <| .Const <| Int64.mk ⟨n, h.right, h.left⟩
        else
          .error s!"Integer literal `n` should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"
  )

private partial def parse' : (ReaderT (IO String) (ExceptT String Parser)) Expr := do
  fun getLine cs =>
    match parser cs with
    | .error .UnexpectedEndOfInput => do
        match getLine () with
        | .ok s _    => parse' getLine <| cs.append s.data
        | .error e _ => Except.error <| Parser.Error.IOError e
    | v => v

-- #eval parse' (pure "0120") "123".data
-- #eval parse' (pure "-1") "".data
-- #eval parse' (pure "9223372036854775808") "".data
-- #eval parse' (pure "9223372036854775808") "".data
-- #eval parse' (pure "0120") "123".data

def parse (stream : IO.FS.Stream) :=
  stream.getLine >>= pure ∘ fun s =>
    match s.data with
    | [] => none
    | cs => some <| parse' stream.getLine cs

def parseLine (line : String) :=
  match line.data with
  | [] => none
  | cs => some <| parse' (pure "") cs
