import Tibi.Compiler
import Tibi.Interpreter
import Tibi.Parser
import Tibi.Tokenizer
import Tibi.Typing

namespace Tibi

partial def repl (stream : IO.FS.Stream) (n : Nat := 0) : IO UInt32 := do
  IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    match tokenize line with
    | .ok [] => pure ()
    | .ok (t :: ts) =>
        match parse t ts with
        | .ok (e, []) =>
            match e.typeCheck with
            | .found t _ =>
                match e.eval with
                | .ok n    => IO.println s!"- : {t} = {n}"
                | .error e => IO.eprintln s!"Runtime Error: {e}"
            | .unknown =>
                IO.eprintln "Type Error"
        | .ok (_, ts) =>
            IO.eprintln s!"Syntax Error: unexpected tokens: {ts}"
        | .error e =>
            IO.eprintln s!"Syntax Error: {e}"
    | .error e =>
        IO.eprintln s!"Syntax Error: {e}"
    repl stream n.succ
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
          | .ok (_, ts) => EStateM.throw s!"Syntax Error: unexpected tokens: {ts}"
          | .error e    => EStateM.throw s!"Syntax Error: {e}"
    )
  >>= (
    fun (e : Option Expr) => do
      match e with
      | .none   => return .none
      | .some e =>
          match e.typeCheck with
          | .found .. => return .some e
          | .unknown  => EStateM.throw "Type Error"
  )
  >>= (
    fun (e : Option Expr) =>
      match e with
      | .none   => return Wasm.build Wasm.empty
      | .some e => return Wasm.build <| Wasm.simple e.compile
    )
