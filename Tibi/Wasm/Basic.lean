import Tibi.Wasm.Util

namespace Wasm

def magic : List UInt8 := [0x00, 0x61, 0x73, 0x6D]
def version : List UInt8 := [0x01, 0x00, 0x00, 0x00]

class Encode (α : Type) where
  encode : α → List UInt8

instance : Encode Nat where
  encode := Nat.encode

instance : Encode UInt8 where
  encode n := [n]

instance : Encode String where
  encode := String.encode

/- # Convensions -/

/- ## Vectors -/

inductive Vec (α : Type) [Encode α]: Nat → Type
| nil : Vec α 0
| cons (a : α) (as : Vec α n) : Vec α n.succ

def Vec.ofList [Encode α] : (v : List α) → Vec α v.length
| []      => Vec.nil
| a :: as => Vec.cons a (Vec.ofList as)

def Vec.toList [Encode α] : Vec α n → List α
| nil       => []
| cons a as => a :: as.toList

def Vec.encode [Encode α] (v : Vec α n) : List UInt8 :=
  n.encode ++ List.join (v.toList.map Encode.encode)

instance [Encode α] : Encode (Vec α n) where
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

instance : Encode ValType where
  encode := ValType.encode

/- ## Function Types -/
structure FuncType (n m : Nat) where
  argTypes : Vec ValType n
  retTypes : Vec ValType m

def FuncType.encode : FuncType n m → List UInt8
| ⟨args, rets⟩ => [0x60] ++ Encode.encode args ++ rets.encode

instance : Encode (FuncType n m) where
  encode := FuncType.encode