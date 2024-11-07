import Tibi.StringReader
import Tibi.Tokenizer

namespace Tibi

private partial def repl (n : Nat) (handle : IO.FS.Handle) : IO UInt32 := do
  let line ← handle.getLine
  if not line.isEmpty then
    match tokenize line with
    | .ok ts =>
        IO.println ts
        repl n.succ handle
    | .error e =>
        IO.eprintln s!"{e} at line {n}"
        return 1
  else
    return 0

def run : IO.FS.Handle → IO UInt32 := repl 1
