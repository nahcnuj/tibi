import Tibi

def main : List String → IO UInt32
| file :: _ => do
    let file := System.FilePath.mk file
    if ← file.pathExists then
      let handle ← IO.FS.Handle.mk file IO.FS.Mode.read
      let stream := IO.FS.Stream.ofHandle handle
      Tibi.run stream
      return 0
    else
      IO.eprintln s!"no such file: {file}"
      return 1
| [] => do
    IO.eprintln "require an input filename"
    return 1
