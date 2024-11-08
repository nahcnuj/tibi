import Tibi.Tokenizer

namespace Tibi

private partial def repl (n : Nat) (stream : IO.FS.Stream) : IO UInt32 := do
  if ← stream.isTty then IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    match tokenize line with
    | .ok ts =>
        IO.println ts
        repl n.succ stream
    | .error e =>
        IO.eprintln s!"{e} at line {n}"
        return 1
  else
    return 0

def run : IO.FS.Stream → IO UInt32 := repl 1
