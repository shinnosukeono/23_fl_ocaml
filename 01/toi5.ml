let rec append a b =
  match a with
  | [] -> b
  | x::xs -> x::(append xs b);;

let rec filter f list =
  match list with
  | [] -> []
  | x::xs ->
    if (f x) then
      x :: filter f xs
    else
      filter f xs;;
