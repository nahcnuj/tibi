import Tibi.Wasm.Instruction
import Tibi.Wasm.Value

namespace Wasm

/- # Wasm Semantics -/

/- ## Wasm Runtime Structure Components -/

/- ### Values -/

open Wasm.Value

inductive Num
| Int32 (i : Int32)
| Int64 (i : Int64)

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
