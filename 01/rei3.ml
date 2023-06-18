let rec map f list =
  match list with
  | [] -> []
  | x :: xs -> f x :: map f xs;;