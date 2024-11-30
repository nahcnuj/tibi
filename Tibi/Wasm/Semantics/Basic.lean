import Tibi.Wasm.Instruction

namespace Wasm

/- # Wasm Semantics -/

/- ## Wasm Runtime Structure Components -/

/- ### Values -/

inductive Num
| Int32 (i : Int) -- FIXME accept only i32
| Int64 (i : Int) -- FIXME accept only i64

inductive Value
| Num (n : Num)

/- ### Activation Frames -/

structure FrameState where
  locals : List Value
  module : Unit

structure Frame where
  arity : Nat
  state : FrameState

/- ### Store -/

structure Store where

/- ### Stack -/

inductive StackValue
| Value (v : Value)
| Frame (f : Frame)

/- ### Configuration -/

structure Configuration where
  stack : List StackValue
  store : Store
  framestate : FrameState
  instrs : List Instr
