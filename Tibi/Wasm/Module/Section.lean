import Tibi.Wasm.Basic
import Tibi.Wasm.Module.Component

namespace Wasm

/- # Module Sections -/

inductive Section : UInt8 → Type
| Types   (ts : Vec FuncType k) : Section  1
| Funcs   (ts : Vec Nat      k) : Section  3
| Exports (es : Vec Export   k) : Section  7
| Code    (cs : Vec Code     k) : Section 10

def Section.body : Section n → List UInt8
| Types   ts => ts.encode
| Funcs   ts => ts.encode
| Exports es => es.encode
| Code    cs => cs.encode

def Section.encode (s : Section n) : List UInt8 :=
  [n]
  ++ s.body.length.encode
  ++ s.body

instance : Encode (Section n) where
  encode := Section.encode
