import Tibi.Syntax
import Tibi.Typing
import Tibi.Wasm

namespace Tibi

open Wasm.Value

inductive CompileError
| OutOfBounds_Int64 (n : Int)
| Unimplemented

def Expr.compile : Expr ctx ty → Except CompileError (List Wasm.Instr)
| .Const n =>
    if h : (-Int64.size : Int) ≤ n ∧ n < Int64.size then
      .ok [.i64__const <| Int64.mk ⟨n, h.right, h.left⟩]
    else
      .error <| .OutOfBounds_Int64 n
| .Var _ =>
    .error .Unimplemented -- TODO: implement compilation of variable expressions
| _ => .error .Unimplemented -- TODO: implement compilation of lambda and application expressions

def CompileError.toString : CompileError → String
| .OutOfBounds_Int64 n => s!"{n} is out of Int64 bounds, should be satisfied that -2{Nat.toSuperscriptString 63} ≤ n < 2{Nat.toSuperscriptString 63}"
| .Unimplemented => "Unimplemented"

instance : ToString CompileError where
  toString := CompileError.toString
