namespace Tibi

section
variable (σ : Type u) [BEq σ] [ToString σ]
variable (ε : Type _) [ToString ε]
variable (m : Type u → Type _) [Monad m]

inductive ParserT.Error
| ExpectedChar (want got : σ)
| UnexpectedEndOfInput
| UserError (e : ε)

protected def ParserT.Error.toString : ParserT.Error σ ε → String
| ExpectedChar want got => s!"Expected '{want}', got '{got}'"
| UnexpectedEndOfInput  => "Unexpected the end of input"
| UserError e           => ToString.toString e

instance : ToString (ParserT.Error σ ε) where
  toString := ParserT.Error.toString σ ε

abbrev ParserT.Result (α : Type _) :=
  ExceptT (ParserT.Error σ ε) m (α × List σ)

def ParserT (α : Type _) :=
  List σ → ParserT.Result σ ε m α

instance : Coe ε (ParserT.Error σ ε) where
  coe := .UserError

end

section

variable {σ : Type u} [BEq σ]
variable {m : Type u → Type v} [Monad m]

namespace ParserT

def pure (a : α) : ParserT σ ε m α := fun s => ExceptT.pure (a, s)

def bind (pa : ParserT σ ε m α) (f : α → ParserT σ ε m β) : ParserT σ ε m β :=
  fun s => ExceptT.mk <|
    pa s
    >>= fun r => match r with
      | .ok (a, s) => f a s
      | .error e   => Pure.pure (f := m) <| Except.error e

end ParserT

instance : Monad (ParserT σ ε m) where
  pure := ParserT.pure
  bind := ParserT.bind

private def ok (a : α) (s : List σ) : ParserT.Result σ ε m α :=
  Except.ok (a, s) (ε := ParserT.Error σ ε)

private def error (e : ParserT.Error σ ε) : ParserT.Result σ ε m α :=
  Except.error e

-- def fail (e : ε) : ParserT σ ε m α := fun _ => throw <| .UserError e

def anyChar : ParserT σ ε m σ
| []      => error ParserT.Error.UnexpectedEndOfInput
| c :: cs => ok c cs

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
