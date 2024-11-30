namespace Tibi

def ExceptT.liftIO [ToString ε] : ExceptT ε Id α → IO α
| .ok a    => .ok a
| .error e => .error <| ToString.toString e

inductive Maybe (p : α → Prop)
| unknown
| found (a : α) : p a → Maybe p

notation "{{ " x " | " p " }}" => Maybe (fun x => p)
