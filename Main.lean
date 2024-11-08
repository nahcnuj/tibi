import Tibi

def main : List String → IO UInt32
| [] | "-" :: _ => do
    Tibi.run (← IO.getStdin)
| file :: _ => do
    let file := System.FilePath.mk file
    if ← file.pathExists then
      IO.FS.withFile file IO.FS.Mode.read (Tibi.run ∘ IO.FS.Stream.ofHandle)
    else
      IO.eprintln s!"no such file: {file}"
      return 1
