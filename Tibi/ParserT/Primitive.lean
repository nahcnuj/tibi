import Tibi.ParserT.Basic

namespace Tibi.ParserT

variable {σ : Type} [BEq σ]
variable {m : Type → Type _} [Monad m]

open Tibi.ParserT (ok error)

-- def fail (e : ε) : ParserT σ ε m α := fun _ => throw <| .UserError e

def anyChar : ParserT σ ε m σ
| []      => error .UnexpectedEndOfInput
| c :: cs => ok c cs

def eof : ParserT σ ε m Unit
| [] => ok () []
| cs => error <| .ExpectedEndOfInput cs

def satisfy (cond : σ → Bool) (mkError : σ → ε) : ParserT σ ε m σ :=
  anyChar
  >>= fun c cs =>
    if cond c then
      ok c cs
    else
      error <| .UserError <| mkError c

def char (ch : σ) : ParserT σ ε m σ :=
  anyChar
  >>= fun c cs =>
    if c == ch then
      ok c cs
    else
      error <| .ExpectedChar ch c
