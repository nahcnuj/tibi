import Tibi.Compiler
import Tibi.Parser
import Tibi.Tokenizer

namespace Tibi

partial def repl (stream : IO.FS.Stream) (n : Nat := 0) : IO UInt32 := do
  if ← stream.isTty then IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    match Tokenizer.tokenize line with
    | .ok ts =>
        IO.println ts
        match parse ts with
        | .ok (e, ts) =>
            IO.println e
            if !ts.isEmpty then IO.eprintln s!"some tokens unconsumed: {ts}"
        | .error e =>
            IO.eprintln <|
              match e with
              | .Err s => s
              | .Unimplemented => "Unimplemented yet"
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
  >>= (
    fun (ts : List Token) => do
      match parse ts with
      | .ok (e, []) => pure e
      | .ok (_, ts) => EStateM.throw <| IO.userError s!"some tokens unconsumed: {ts}"
      | .error e => EStateM.throw <| IO.userError s!"{e}"
    )
  >>= fun (_ : Expr) =>
    return compile
