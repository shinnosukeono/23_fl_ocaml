let rec remove x list =
  match list with
  | [] -> []
  | y::ys -> if x = y then remove x ys else y::(remove x ys);;

let rec list_len_sub list acc =
  match list with
  | [] -> acc
  | x::xs -> list_len_sub xs (acc + 1);;

let list_len list = list_len_sub list 0;;

let rec fold_right f list e=
  match list with
  | [] -> e
  | x::xs -> fold_right f xs (f x e);;

let perm list =
  let rec permutation n list a b=
    if n = 0 then a::b
    else fold_right (fun x y -> permutation (n - 1) (remove x list) (x::a) y) list b
  in
    permutation (list_len list) list [] [];;