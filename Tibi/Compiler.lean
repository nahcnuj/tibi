import Tibi.Syntax
import Tibi.Wasm

namespace Tibi

open Wasm.Value

inductive CompileError
| OutOfBounds_Int64 (n : Int)

def Expr.compile : Expr → Except CompileError (List Wasm.Instr)
| .Const n =>
    if h : (-Int64.size : Int) ≤ n ∧ n < Int64.size then
      .ok [.i64__const <| Int64.mk ⟨n, h.right, h.left⟩]
    else
      .error <| .OutOfBounds_Int64 n

def CompileError.toString : CompileError → String
| .OutOfBounds_Int64 n => s!"{n} is out of Int64 bounds, should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"

instance : ToString CompileError where
  toString := CompileError.toString
