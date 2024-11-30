import Tibi.Compiler
import Tibi.Interpreter
import Tibi.Parser
import Tibi.Tokenizer

namespace Tibi

partial def repl (stream : IO.FS.Stream) (n : Nat := 0) : IO UInt32 := do
  if ← stream.isTty then IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    match tokenize line with
    | .ok [] =>
        repl stream n.succ
    | .ok (t :: ts) =>
        match parse t ts with
        | .ok (e, ts) =>
            match e.eval with
            | .ok n    => IO.println n
            | .error _ => IO.eprintln "Error!"
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

private partial def tokenize' (stream : IO.FS.Stream) (tokens : List Token) : IO (List Token) := do
  let line ← stream.getLine
  if line.isEmpty then
    return tokens
  else
    tokenize line
    >>= fun (ts : List Token) => tokenize' stream (tokens ++ ts)

def run (inStream : IO.FS.Stream) : IO ByteArray :=
  tokenize' inStream []
  >>= (
    fun (ts : List Token) =>
      match ts with
      | []      => return none
      | t :: ts =>
          match parse t ts with
          | .ok (e, []) => return e
          | .ok (_, ts) => EStateM.throw <| IO.userError s!"some tokens unconsumed: {ts}"
          | .error e    => EStateM.throw <| IO.userError s!"{e}"
    )
  >>= (
    fun (e : Option Expr) =>
      match e with
      | .none   => return Wasm.build Wasm.empty
      | .some e => return Wasm.build <| Wasm.simple e.compile
    )
