import Tibi.Compiler
import Tibi.Semantics
import Tibi.Wasm.Semantics

namespace Tibi

/-
type mismatch
  Wasm.Reduction.local__get ↑x.idx
has type
  Wasm.Reduction
    { stack := ?m.4159, store := ?m.4160, framestate := ?m.4161, instrs := Wasm.Instr.local.get ↑x.idx :: ?m.4162 }
    { stack := Wasm.StackValue.Value (?m.4161.locals.get! ↑x.idx) :: ?m.4159, store := ?m.4160, framestate := ?m.4161,
      instrs := ?m.4162 } : Prop
but is expected to have type
  Wasm.Reduction
    { stack := stack, store := store, framestate := framestate, instrs := [Wasm.Instr.local.get ↑x.idx] ++ K }
    { stack := Wasm.StackValue.Value (Wasm.Value.Num (Wasm.Num.Int64 (Env.lookup x env))) :: stack, store := store,
      framestate := framestate, instrs := K } : Prop

theorem Wasm.Reduction.of_has_type_of_eval_ok_of_compile_ok
: {e : Expr ctx ty} → HasType env e _ty → Eval env e (.ok v) → {_ : e.compile = .ok instrs}
→ Wasm.Reduction
    { instrs := instrs ++ K, stack,                                      store, framestate }
    { instrs := K,           stack := .Value (.Num (.Int64 v)) :: stack, store, framestate }
| .Const n, .Int64 hLt hGe, .Const _ _, hc => by
    have : (Expr.Const n : Expr ctx ty).compile = .ok [.i64.const (Int64.mk ⟨n, hLt, hGe⟩)] := by
      -- dsimp [Expr.compile]
      apply dite_cond_eq_true <| eq_true <| And.intro hGe hLt
    have : instrs = [.i64.const ⟨n, hLt, hGe⟩] := Except.ok.inj <| Eq.trans hc.symm this
    rw [this]
    exact .i64.const
| .Var x, .Var, .Var _, hc => by
    have : (Expr.Var x : Expr ctx ty).compile = .ok [.local.get x.idx] := rfl
    have : instrs = [.local.get x.idx] := Except.ok.inj <| Eq.trans hc.symm this
    rw [this]
    exact .local.get x.idx
-/
