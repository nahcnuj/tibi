namespace Tibi

/- # Finite Integers -/

/--
`FinInt` is an integer `i` with the constraint that `-n ≤ i < n` like `Fin`.
-/
structure FinInt (m : Nat) where
  val : Int
  isLt : val < m
  isGe : -m ≤ val

def FinInt.ofFin : Fin m → FinInt m
| ⟨n, h⟩ =>
    FinInt.mk n
      (Int.ofNat_lt.mpr h)
      (calc -Int.ofNat m
        _ ≤ -n := Int.le_of_lt <| Int.neg_lt_neg (Int.ofNat_le.mpr h)
        _ ≤ 0  := Int.neg_nonpos_of_nonneg (Int.ofNat_nonneg _)
        _ ≤ n  := Int.ofNat_nonneg _
      )

/- ## Int32 -/

abbrev Int32.size : Nat := 2147483648
example : Int32.size = 2^31 := rfl

structure Int32 where
  val : FinInt Int32.size

def Int32.ofFin : Fin Int32.size → Int32 := Int32.mk ∘ FinInt.ofFin

/- ## Int64 -/

abbrev Int64.size : Nat := 9223372036854775808
example : Int64.size = 2^63 := rfl

structure Int64 where
  val : FinInt Int64.size

def Int64.ofFin : Fin Int64.size → Int64 := Int64.mk ∘ FinInt.ofFin

def Int64.toString (i : Int64) : String := Int.repr i.val.val

instance : ToString Int64 where
  toString := Int64.toString
