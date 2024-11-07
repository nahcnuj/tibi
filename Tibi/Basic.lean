inductive Token
| T (c : Char)

instance : ToString Token where
  toString
  | .T c => s!"<T {c}>"
