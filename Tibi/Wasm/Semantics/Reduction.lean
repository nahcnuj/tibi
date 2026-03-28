import Tibi.Wasm.Instruction
import Tibi.Wasm.Semantics.Basic
import Tibi.Wasm.Value

namespace Wasm

open Wasm.Value

/- # Wasm Reduction -/

inductive Reduction : Configuration → Configuration → Prop
| i32.const {i : Int32} : Reduction
    { instrs := .i32.const i :: K, stack := s,                             store, framestate }
    { instrs := K,                  stack := .Value (.Num (.Int32 i)) :: s, store, framestate }
| i64.const {i : Int64} : Reduction
    { instrs := .i64.const i :: K, stack := s,                             store, framestate }
    { instrs := K,                  stack := .Value (.Num (.Int64 i)) :: s, store, framestate }
| local.get (n : Nat) : Reduction
    { instrs := .local.get n :: K, stack := s,                                      store, framestate }
    { instrs := K,                  stack := .Value (framestate.locals.get! n) :: s, store, framestate }
