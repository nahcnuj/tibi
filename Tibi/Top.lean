import Tibi.Tokenizer

namespace Tibi

private partial def repl (n : Nat) (stream : IO.FS.Stream) : IO UInt32 := do
  if ← stream.isTty then IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    match Tokenizer.tokenize line with
    | .ok ts =>
        IO.println ts
        repl n.succ stream
    | .error e =>
        IO.eprintln <|
          match e with
          | .Unconsumed s => s!"unknown tokens found at line {n}: {s}"
        if ← stream.isTty then
          repl n.succ stream
        else
          return 1
  else
    return 0

def run : IO.FS.Stream → IO UInt32 := repl 1
