namespace Tibi

section
variable (σ : Type) [BEq σ] [ToString σ]
variable (ε : Type) [ToString ε]
variable (m : Type → Type _) [Monad m]

inductive ParserT.Error
| ExpectedChar (want got : σ)
| ExpectedEndOfInput (s : List σ)
| UnexpectedEndOfInput
| UserError (e : ε)

protected def ParserT.Error.toString : ParserT.Error σ ε → String
| ExpectedChar want got => s!"Expected '{want}', got '{got}'"
| ExpectedEndOfInput s  => s!"Expected EOF, got \"{String.join <| List.map ToString.toString s}\""
| UnexpectedEndOfInput  => "Unexpected the end of input"
| UserError e           => ToString.toString e

instance : ToString (ParserT.Error σ ε) where
  toString := ParserT.Error.toString σ ε

abbrev ParserT.Result (α : Type) :=
  ExceptT (ParserT.Error σ ε) m (α × List σ)

def ParserT (α : Type) :=
  List σ → ParserT.Result σ ε m α

instance : Coe ε (ParserT.Error σ ε) where
  coe := .UserError

end

namespace ParserT

variable {σ : Type} [BEq σ]
variable {m : Type → Type _} [Monad m]

def pure (a : α) : ParserT σ ε m α := fun s => ExceptT.pure (a, s)

def bind (pa : ParserT σ ε m α) (f : α → ParserT σ ε m β) : ParserT σ ε m β :=
  fun s => ExceptT.mk <|
    pa s
    >>= fun r => match r with
      | .ok (a, s) => f a s
      | .error e   => Pure.pure (f := m) <| Except.error e

instance : Monad (ParserT σ ε m) where
  pure := ParserT.pure
  bind := ParserT.bind

protected def ok (a : α) (s : List σ) : ParserT.Result σ ε m α :=
  Except.ok (a, s) (ε := ParserT.Error σ ε)

protected def error (e : ParserT.Error σ ε) : ParserT.Result σ ε m α :=
  Except.error e

def map (f : α → β) (p : ParserT σ ε m α) : ParserT σ ε m β :=
  p
  >>= fun a => pure (f a)
