import Tibi.Wasm.Instruction
import Tibi.Wasm.Semantics.Basic
import Tibi.Wasm.Value

namespace Wasm

open Wasm.Value

/- # Wasm Reduction -/

inductive Reduction : Configuration → Configuration → Prop
| i32__const {i : Int32} : Reduction
    { instrs := .i32__const i :: K, stack := s,                             store, framestate }
    { instrs := K,                  stack := .Value (.Num (.Int32 i)) :: s, store, framestate }
| i64__const {i : Int64} : Reduction
    { instrs := .i64__const i :: K, stack := s,                             store, framestate }
    { instrs := K,                  stack := .Value (.Num (.Int64 i)) :: s, store, framestate }
