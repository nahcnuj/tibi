namespace Tibi.Combinator

def choice {α β : Type u} : List (α → Option (β × α)) → α → Option (β × α)
  | []      => fun _ => .none
  | p :: ps => fun s => p s <|> choice ps s
