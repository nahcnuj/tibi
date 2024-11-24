import Tibi

def main : List String → IO UInt32
| [] | "-" :: _ => do
    Tibi.repl (← IO.getStdin)
| file :: _ => do
    let file := System.FilePath.mk file
    if ← file.pathExists then
      let bin ← IO.FS.withFile file IO.FS.Mode.read (Tibi.run ∘ IO.FS.Stream.ofHandle)
      let dest ← IO.getStdout
      dest.write bin
      return 0
    else
      IO.eprintln s!"no such file: {file}"
      return 1
