import Tibi.ParserT.Basic

namespace Tibi.ParserT

variable {σ : Type} [BEq σ] [ToString σ]
variable {m : Type → Type _} [Monad m]

private partial def repeatGreedily' (p : ParserT σ ε m α) (xs : List α) : ParserT σ ε m (List α) :=
  fun cs => ExceptT.mk <|
    p cs
    >>= fun r => match r with
      | .ok (a, cs) => repeatGreedily' p (a :: xs) cs
      | .error _    => ParserT.ok xs cs

def repeatGreedily (p : ParserT σ ε m α) : ParserT σ ε m (List α) :=
  repeatGreedily' p []
