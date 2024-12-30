import Tibi.Compiler
import Tibi.Semantics
import Tibi.Wasm.Semantics

namespace Tibi

theorem Expr.compile_correct {e : Expr}
: ∀ _ : Eval e (.ok v),
    Wasm.Reduction
      { instrs := e.compile ++ K, stack := ss,                             store, framestate }
      { instrs := K,              stack := .Value (.Num (.Int64 v)) :: ss, store, framestate }
| .Const => Wasm.Reduction.i64__const

-- := by
--   induction hv with
--   | Const =>
--       dsimp [Expr.compile]
--       exact Wasm.Reduction.i64__const
