import Tibi.Compiler
import Tibi.Interpreter
import Tibi.Parser
import Tibi.Typing

namespace Tibi

partial def repl (stream : IO.FS.Stream) (n : Nat := 0) : IO UInt32 := do
  IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    if let some r := parseLine line.trimRight then
      match r with
      | .ok (.ok expr, []) =>
          match expr.typeCheck with
          | .found t _ =>
              match expr.eval with
              | .ok n    => IO.println s!"- : {t} = {n}"
              | .error e => IO.eprintln s!"Runtime Error: {e}"
          | .unknown =>
              IO.eprintln "Type Error"
      | .ok (.error e, []) => IO.eprintln s!"Error: {e}"
      | .ok (_,        cs) => IO.eprintln s!"Syntax Error: Unexpected tokens: {String.mk cs}"
      | .error e           => IO.eprintln e.toString
    repl stream n.succ
  else
    return 0

def run (inStream : IO.FS.Stream) : IO ByteArray :=
  parse inStream
  >>= (
    fun r =>
      match r with
      | .none                       => return none
      | .some <| .ok (.ok expr, []) => return some expr
      | .some <| .ok (.error e, []) => .throw s!"Error: {e}"
      | .some <| .ok (_,        cs) => .throw s!"Syntax Error: Unexpected tokens: {String.mk cs}"
      | .some <| .error e           => .throw e.toString
  )
  >>= (
    pure ∘ fun (e : Option Expr) =>
      match e with
      | .none   => Wasm.empty
      | .some e => Wasm.simple e.compile
  )
  >>= pure ∘ Wasm.build
