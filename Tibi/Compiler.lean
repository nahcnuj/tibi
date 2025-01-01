import Tibi.Syntax
import Tibi.Typing
import Tibi.Wasm

namespace Tibi

open Wasm.Value

inductive CompileError
| OutOfBounds_Int64 (n : Int)

def Expr.compile : Expr ctx ty → Except CompileError (List Wasm.Instr)
| .Const n =>
    if h : (-Int64.size : Int) ≤ n ∧ n < Int64.size then
      .ok [.i64.const <| Int64.mk ⟨n, h.right, h.left⟩]
    else
      .error <| .OutOfBounds_Int64 n
| .Var x =>
    .ok [.local.get x.idx]

def CompileError.toString : CompileError → String
| .OutOfBounds_Int64 n => s!"{n} is out of Int64 bounds, should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"

instance : ToString CompileError where
  toString := CompileError.toString
