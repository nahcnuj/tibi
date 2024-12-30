import Tibi.Wasm.Encoder
import Tibi.Wasm.Util

namespace Wasm

/- # Convensions -/

/- ## Vectors -/

inductive Vec (α : Type) [Encoder α]: Nat → Type
| nil : Vec α 0
| cons (a : α) (as : Vec α n) : Vec α n.succ

def Vec.ofList [Encoder α] : (v : List α) → Vec α v.length
| []      => Vec.nil
| a :: as => Vec.cons a (Vec.ofList as)

def Vec.toList [Encoder α] : Vec α n → List α
| nil       => []
| cons a as => a :: as.toList

def Vec.encode [Encoder α] (v : Vec α n) : List UInt8 :=
  Nat.encode n ++ List.flatten (v.toList.map Encoder.encode)

instance [Encoder α] : Encoder (Vec α n) where
  encode := Vec.encode

/- # Types -/

/- ## Number Types -/

inductive NumType
| Int32
| Int64
| Float32
| Float64

def NumType.encode : NumType → List UInt8
| Int32   => [0x7F]
| Int64   => [0x7E]
| Float32 => [0x7D]
| Float64 => [0x7C]

/- ## Value Types -/

inductive ValType
| NumType (t : NumType)

def ValType.encode : ValType → List UInt8
| NumType t => t.encode

instance : Encoder ValType where
  encode := ValType.encode

/- ## Function Types -/
structure FuncType where
  argTypes : List ValType
  retTypes : List ValType

def FuncType.encode : FuncType → List UInt8
| ⟨args, rets⟩ => 0x60 :: Encoder.encode (Vec.ofList args) ++ Encoder.encode (Vec.ofList rets)

instance : Encoder FuncType where
  encode := FuncType.encode
