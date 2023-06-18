let rec list_len_sub list acc =
  match list with
  | [] -> acc
  | x::xs -> list_len_sub xs (acc + 1);;

let list_len list = list_len_sub list 0;;

let rec get_right list=
  match list with
  | x :: [] -> x
  | x::xs -> get_right xs;;

let rec get_first list =
  match list with
  | x::xs -> x;;
  
let rec remove_first list =
  match list with
  | x::xs -> xs;;

let rec get_until_nth n list =
  if n = 0 then [] else (get_first list) :: (get_until_nth (n - 1) (remove_first list));;

let rec fold_left f e list=
  match list with
  | [] -> e
  | x::xs -> fold_left f (f e x) xs;;

let rec fold_right f list e=
  match list with
  | [] -> e
  | x::xs -> fold_right f (get_until_nth ((list_len list) - 1) list) (f (get_right list) e);;