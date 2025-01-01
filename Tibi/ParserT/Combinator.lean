import Tibi.ParserT.Basic

namespace Tibi.ParserT

variable {σ : Type} [BEq σ] [ToString σ]
variable {m : Type → Type _} [Monad m]

def hAndThen (p : ParserT σ ε m α) (q : Unit → ParserT σ ε m β) : ParserT σ ε m (α × β) :=
  p
  >>= fun a => q ()
  >>= fun b => ParserT.ok (a, b)

instance : HAndThen (ParserT σ ε m α) (ParserT σ ε m β) (ParserT σ ε m (α × β)) where
  hAndThen := hAndThen

def hAndThen' (p : ParserT σ ε m Unit) (q : Unit → ParserT σ ε m β) : ParserT σ ε m β :=
  p
  >>= fun _ => q ()
  >>= fun b => ParserT.ok b

instance : HAndThen (ParserT σ ε m Unit) (ParserT σ ε m β) (ParserT σ ε m β) where
  hAndThen := hAndThen'

def hAndThen'' (p : ParserT σ ε m α) (q : Unit → ParserT σ ε m Unit) : ParserT σ ε m α :=
  p
  >>= fun a => q ()
  >>= fun _ => ParserT.ok a

instance : HAndThen (ParserT σ ε m α) (ParserT σ ε m Unit) (ParserT σ ε m α) where
  hAndThen := hAndThen''

-- def hOrElse (p : ParserT σ ε m α) (q : Unit → ParserT σ ε m β) : ParserT σ ε m (α ⊕ β) :=
--   fun cs =>
--     ExceptT.tryCatch
--       (p cs >>= fun (a, cs) => ParserT.ok (Sum.inl a) cs)
--       (fun _ => q () cs >>= fun (b, cs) => ParserT.ok (Sum.inr b) cs)

-- instance : HOrElse (ParserT σ ε m α) (ParserT σ ε m β) (ParserT σ ε m (α ⊕ β)) where
--   hOrElse := hOrElse

def orElse (p : ParserT σ ε m α) (q : Unit → ParserT σ ε m α) : ParserT σ ε m α :=
  fun cs => p cs |>.tryCatch (fun _ => q () cs)

instance : OrElse (ParserT σ ε m α) where
  orElse := orElse

def not (p : ParserT σ ε m α) (mkError : α → ε) : ParserT σ ε m Unit :=
  fun cs => ExceptT.mk <|
    p cs
    >>= fun r => match r with
      | .ok (a, _) => ParserT.error <| mkError a
      | .error _   => ParserT.ok () cs

def diff (p : ParserT σ ε m α) (q : ParserT σ ε m β) (mkError : β → ε) : ParserT σ ε m α :=
  not q mkError
  >>= fun _ => p

private partial def repeatGreedily' (p : ParserT σ ε m α) (as : List α) : ParserT σ ε m (List α) :=
  fun cs => ExceptT.mk <|
    p cs
    >>= fun r => match r with
      | .ok (a, cs) => repeatGreedily' p (a :: as) cs
      | .error _    => ParserT.ok as cs

def repeatGreedily (p : ParserT σ ε m α) : ParserT σ ε m (List α) :=
  repeatGreedily' p []

def repeatUpTo (p : ParserT σ ε m α) (as : List α) : Nat → ParserT σ ε m (List α)
| 0   => ParserT.ok as
| n+1 =>
    fun cs => ExceptT.mk <|
      p cs
      >>= fun r => match r with
        | .ok (a, cs) => repeatUpTo p (a :: as) n cs
        | .error _    => ParserT.ok as cs

abbrev optional (p : ParserT σ ε m α) :=
  repeatUpTo p [] 1
