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
| Unconsumed (rest : String)

def Parser.Error.toString : Parser.Error → String
| ExpectedDigit got => s!"Expected a digit, got '{got}'"
| Unconsumed rest => s!"\"{rest}\" was not consumed"

instance : ToString Parser.Error where
  toString := Parser.Error.toString

abbrev Parser := ParserT Char Parser.Error Id

private def digit : Parser Nat :=
  ParserT.satisfy Char.isDigit .ExpectedDigit
  |> ParserT.map (fun c => c.toNat - '0'.toNat)

private def digits : Parser (List Nat) :=
  ParserT.repeatGreedily digit

private def parser /- : Parser Syntax.Expr -/ := digits

abbrev parse (s : String) := parser s.data

#eval parse ""
#eval parse "0"
#eval parse "123"
#eval parse "0120"
#eval parse "-1"
