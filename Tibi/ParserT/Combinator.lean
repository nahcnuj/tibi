import Tibi.ParserT.Basic

namespace Tibi.ParserT

variable {σ : Type} [BEq σ] [ToString σ]
variable {m : Type → Type _} [Monad m]

def not (p : ParserT σ ε m α) (mkError : α → ε) : ParserT σ ε m Unit :=
  fun cs => ExceptT.mk <|
    p cs
    >>= fun r => match r with
      | .ok (a, _) => ParserT.error <| mkError a
      | .error _   => ParserT.ok () cs

def diff (p : ParserT σ ε m α) (q : ParserT σ ε m β) (mkError : β → ε) : ParserT σ ε m α :=
  not q mkError
  >>= fun _ => p

private partial def repeatGreedily' (p : ParserT σ ε m α) (xs : List α) : ParserT σ ε m (List α) :=
  fun cs => ExceptT.mk <|
    p cs
    >>= fun r => match r with
      | .ok (a, cs) => repeatGreedily' p (a :: xs) cs
      | .error _    => ParserT.ok xs cs

def repeatGreedily (p : ParserT σ ε m α) : ParserT σ ε m (List α) :=
  repeatGreedily' p []
