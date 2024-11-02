import Tibi

open TM

def program : Program :=
  (.M, [
    ((.M, .I), (.M, .O, .Left)),
    ((.M, .O), (.H, .I, .Left)),
    ((.M, .B), (.H, .I, .Left)),
  ])

def tape := Tape.mk [.I, .I, .I] .I []

def main : IO Unit :=
  let r := program.eval tape
  IO.println s!"[{tape}] => [{r}]"
