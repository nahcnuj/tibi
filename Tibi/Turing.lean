namespace TM

inductive Direction
| Right
| Left

inductive Symbol
| B
| I
| O
deriving BEq, Repr

instance : ToString Symbol where
  toString
  | .B => " "
  | .I => "1"
  | .O => "0"

inductive State
| M
| H
deriving BEq

abbrev Transition := List ((State × Symbol) × (State × Symbol × Direction))

structure Tape where
  left : List Symbol
  current : Symbol
  right : List Symbol
deriving Repr

instance : ToString Tape where
  toString
  | { left, current, right } => String.join (List.map toString (left ++ current :: right))

def Tape.moveLeft : Tape → Tape
  | { left := next :: tail, current, right } => .mk tail next (current :: right)
  | { left := [],           current, right } => .mk []   .B   (current :: right)

def Tape.moveRight : Tape → Tape
  | { left, current, right := next :: tail } => .mk (current :: left) next tail
  | { left, current, right := [] }           => .mk (current :: left) .B   []

def Tape.move : Direction → Tape → Tape
  | .Left  => moveLeft
  | .Right => moveRight

partial def Transition.exec (transition : Transition) (q : State) (tape : Tape) : Tape :=
  match transition.lookup (q, tape.current) with
  | none            => tape
  | some (q', s, d) => exec transition q' <| Tape.move d { tape with current := s }

abbrev Program := State × Transition

def Program.eval : Program → Tape → Tape := fun (q, transition) tape => transition.exec q tape
