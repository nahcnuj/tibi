namespace Tibi

def ExceptT.liftIO [ToString ε] : ExceptT ε Id α → IO α
| .ok a    => .ok a
| .error e => .error <| ToString.toString e
