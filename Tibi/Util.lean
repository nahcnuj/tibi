namespace Tibi

def ExceptT.liftIO [ToString ε] : ExceptT ε Id α → IO α
| .ok a    => .ok a
| .error e => .error <| ToString.toString e

inductive Maybe (p : α → Prop)
| unknown
| found (a : α) : p a → Maybe p

notation "{{ " x " | " p " }}" => Maybe (fun x => p)

inductive Vec (α : Type u) : Nat → Type u
| nil : Vec α 0
| cons : α → Vec α n → Vec α n.succ

infixr:67 " :: " => Vec.cons
