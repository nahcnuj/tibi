import Tibi.StringReader

namespace Tibi

private partial def repl (reader : StringReader) : IO Unit := do
  if let some reader ← reader.skipSpaces then
    let (reader, s) ← reader.readString
    IO.println s
    repl reader
  else
    pure ()

def run (stream : IO.FS.Stream) : IO Unit := do
  repl <| StringReader.ofStream stream
