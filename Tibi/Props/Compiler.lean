import Tibi.Compiler
import Tibi.Semantics
import Tibi.Wasm.Semantics

namespace Tibi

theorem Wasm.Reduction.of_has_type_of_eval_ok_of_compile_ok -- Expr.compile_ok_of_has_type_of_eval
: {e : Expr} → HasType e _ty → Eval e (.ok v) → {_ : e.compile = .ok instrs}
→ Wasm.Reduction
    { instrs := instrs ++ K, stack,                                      store, framestate }
    { instrs := K,           stack := .Value (.Num (.Int64 v)) :: stack, store, framestate }
| .Const n, .Int64 hLt hGe, .Const _ _, hc => by
    have : (Expr.Const n).compile = .ok [.i64__const (Int64.mk ⟨n, hLt, hGe⟩)] := by
      -- dsimp [Expr.compile]
      apply dite_cond_eq_true <| eq_true <| And.intro hGe hLt
    have : instrs = [.i64__const ⟨n, hLt, hGe⟩ ] := Except.ok.inj <| Eq.trans hc.symm this
    rw [this]
    exact .i64__const
