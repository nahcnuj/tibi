import Tibi.Compiler
import Tibi.Interpreter
import Tibi.Parser
import Tibi.Typing

namespace Tibi

partial def repl (stream : IO.FS.Stream) (n : Nat := 0) : IO UInt32 := do
  if ← stream.isTty then IO.print s!"{n}:> "
  let line ← stream.getLine
  if not line.isEmpty then
    if let some r := parseLine line then
      match r with
      | .ok (expr, []) =>
          match expr.typeCheck with
          | .found t _ =>
              match expr.eval .nil () with
              | .found (.ok v) _    => IO.println s!"- : {t} = {v}"
              | .found (.error _) _ => panic! "TODO: prove that this branch cannot be reached (type-safe)"
              | .unknown            => panic! "TODO: prove that this branch cannot be reached (type-safe)"
          | .unknown =>
              IO.eprintln "Type Error"
      | .ok (_, cs) => IO.eprintln s!"Syntax Error: Unexpected tokens: {String.mk cs}"
      | .error e    => IO.eprintln e.toString
    repl stream n.succ
  else
    return 0

def run (inStream : IO.FS.Stream) : IO ByteArray :=
  parse inStream
  >>= (
    fun r =>
      match r with
      | .none                   => return none
      | .some <| .ok (expr, []) => return some expr
      | .some <| .ok (_,    cs) => .throw s!"Syntax Error: Unexpected tokens: {String.mk cs}"
      | .some <| .error e       => .throw e.toString
  )
  >>= (
    fun (e : Option (Expr _ _)) =>
      match e with
      | .none   => pure Wasm.empty
      | .some e =>
          match e.compile with
          | .ok b    => return Wasm.simple b
          | .error e => .throw s!"Compile Error: {e}"
  )
  >>= pure ∘ Wasm.build
