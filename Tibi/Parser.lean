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

private def ws : Parser Unit :=
  (
    ParserT.repeatGreedily <|
      ParserT.satisfy (fun c => c == ' ' || c == '\n' || c == '\r' || c == '\t' ) .ExpectedDigit
  ) |>.map fun _ => ()

private def keyword (s : String) : Parser Unit :=
  s.data.map ParserT.char |>.foldl (fun r p => r >>= fun _ => p |>.map fun _ => ()) (.ok ())

private def digit : Parser Nat :=
  ParserT.satisfy Char.isDigit .ExpectedDigit
    |>.map fun c => c.toNat - '0'.toNat

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

private def parser : Parser Expr :=
  (
    natNumber >> ws -- >> ParserT.optional ((ParserT.char '@' : Parser _) >> keyword "Int" >> ws)
      |>.map fun (n, _) => .Const n
  )
  <|> (
    intNumber >> ws -- >> ParserT.optional ((ParserT.char '@' : Parser _) >> keyword "Int" >> ws)
      |>.map fun (n, _) => .Const n
  )

instance : Inhabited (Parser Expr) where
  default := parser

private partial def parse' : ReaderT (IO String) Parser Expr := do
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
