namespace Tibi

section
variable (σ : Type _)
variable (ε : Type _) [ToString ε]
variable (m : Type _ → Type _) [Monad m]

inductive ParserT.Error
| UnexpectedEndOfInput
| UserError (e : ε)

protected def ParserT.Error.toString : ParserT.Error ε → String
| UnexpectedEndOfInput => "Unexpected the end of input"
| UserError e          => ToString.toString e

instance : ToString (ParserT.Error ε) where
  toString := ParserT.Error.toString ε

abbrev ParserT.Result (α : Type _) :=
  ExceptT (ParserT.Error ε) m (α × List σ)

def ParserT (α : Type _) :=
  List σ → ParserT.Result σ ε m α

instance : Coe ε (ParserT.Error ε) where
  coe := .UserError

end

section

open ParserT (Error)

variable {σ : Type _}
variable {ε : Type _} [ToString ε]
variable {m : Type _ → Type _} [Monad m]

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

private def ok (a : α) (s : List σ) : ExceptT (ParserT.Error ε) m (α × List σ) :=
  Except.ok (a, s) (ε := Error ε)

private def error (e : Error ε) : ExceptT (ParserT.Error ε) m (α × List σ) :=
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

#check ExceptT



-- だ
-- □゙
-- ◌゙
