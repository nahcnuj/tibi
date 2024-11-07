import Tibi

def main : List String → IO UInt32
| file :: _ => do
    let file := System.FilePath.mk file
    if ← file.pathExists then
      IO.FS.withFile file IO.FS.Mode.read Tibi.run
      return 0
    else
      IO.eprintln s!"no such file: {file}"
      return 1
| [] => do
    IO.eprintln "require an input filename"
    return 1
