import Tibi.ParserT
import Tibi.Syntax

namespace Tibi

inductive Parser.Error
| ExpectedAsciiAlpha    (got : Char)
| ExpectedAsciiAlphaNum (got : Char)
| ExpectedDigit         (got : Char)
| ExpectedNonZeroDigit  (got : Char)
| IOError               (e : IO.Error)
| Unconsumed (rest : String)

def Parser.Error.toString : Parser.Error → String
| ExpectedAsciiAlpha got    => s!"Expected an ASCII alphabet character, got '{got}'"
| ExpectedAsciiAlphaNum got => s!"Expected an ASCII alphanumeric character, got '{got}'"
| ExpectedDigit got         => s!"Expected a digit, got '{got}'"
| ExpectedNonZeroDigit got  => s!"Expected a non-zero digit, got '{got}'"
| IOError e                 => s!"IO Error: {e}"
| Unconsumed rest           => s!"\"{rest}\" was not consumed"

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

private def enclose (pre : String) (p : Parser α) (post : String) : Parser α :=
  keyword pre >> ws >> p >> ws >> keyword post

private def asciiAlpha : Parser Char :=
  ParserT.satisfy Char.isAlpha .ExpectedAsciiAlpha

private def asciiAlphanum : Parser Char :=
  ParserT.satisfy Char.isAlphanum .ExpectedAsciiAlphaNum

private def ident : Parser String :=
  (
    asciiAlpha >> ParserT.repeatGreedily asciiAlphanum
      |>.map fun (c, cs) => String.mk (c :: cs)
  )

private def var : Parser String :=
  keyword "$" >> ident

instance : Inhabited (Parser (Expr ctx .int)) where
  default := intNumber.map Expr.Const

mutual

  partial def cls (x : Locals i ctx dom) : Parser (Expr ctx dom) :=
    (
      var >> ws
        |>.map fun _ => .Var x
    )

  partial def fn : Parser (Expr ctx (.fn .int .int)) :=
    (
      var >> ws >> keyword "." >> ws >> cls (Locals.stop) >> ws
        |>.map fun (_, e) => Expr.Lam e
    )

  partial def expr : Parser (Expr .nil .int) :=
    (
      natNumber >> ws -- >> ParserT.optional ((ParserT.char '@' : Parser _) >> keyword "Int" >> ws)
        |>.map fun n => .Const n
    )
    <|> (
      intNumber >> ws -- >> ParserT.optional ((ParserT.char '@' : Parser _) >> keyword "Int" >> ws)
        |>.map fun n => .Const n
    )
    <|> (
      enclose "(" fn ")" >> ws >> expr >> ws
        |>.map fun (f, e) => .App f e
    )
    -- <|> (
    --   keyword "it" >> ws
    --     |>.map fun _ => .Var .stop
    -- )
end

private partial def parse' : ReaderT (IO String) Parser (Expr .nil .int) := do
  fun getLine cs =>
    match expr cs with
    | .ok (e, []) =>
        match getLine () with
        | .ok s _    =>
            if s.isEmpty then
              .ok (e, [])
            else
              .error $ .ExpectedEndOfInput s.trimRight.data
        | .error e _ =>
            .error $ Parser.Error.IOError e
    | .ok (_, cs) =>
        .error $ .ExpectedEndOfInput cs
    | .error .UnexpectedEndOfInput => -- continue to parse furthermore
        match getLine () with
        | .ok s _    =>
            if s.isEmpty then
              .error $ .UnexpectedEndOfInput
            else
              parse' getLine $ cs.append s.data
        | .error e _ => .error $ Parser.Error.IOError e
    | v => v

def parse (stream : IO.FS.Stream): IO (Option (ParserT.Result Char Parser.Error Id (Expr .nil .int))) :=
  stream.getLine >>= pure ∘ fun s =>
    match s.data with
    | [] => none
    | cs => some <| parse' stream.getLine cs

def parseLine (line : String) : Option (ParserT.Result Char Parser.Error Id (Expr .nil .int)) :=
  match line.data with
  | [] => none
  | cs => some <| parse' (pure "") cs
