import Tibi.Compiler
import Tibi.Tokenizer

namespace Tibi

partial def repl (stream : IO.FS.Stream) (n : Nat := 0) : IO UInt32 := do
  if ← stream.isTty then IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    match Tokenizer.tokenize line with
    | .ok ts =>
        IO.println ts
        repl stream n.succ
    | .error e =>
        IO.eprintln <|
          match e with
          | .Unconsumed s => s!"unknown tokens found at line {n}: {s}"
        if ← stream.isTty then
          repl stream n.succ
        else
          return 1
  else
    return 0

private partial def tokenize (stream : IO.FS.Stream) (tokens : List Token) : IO (List Token) := do
  let line ← stream.getLine
  if line.isEmpty then
    return tokens
  else
    match Tokenizer.tokenize line with
    | .ok ts =>
        tokenize stream (tokens ++ ts)
    | .error e =>
        EStateM.throw <| IO.userError s!"{e}"

def run (inStream : IO.FS.Stream) : IO ByteArray :=
  tokenize inStream []
  >>= fun (_ : List Token) =>
    return compile
