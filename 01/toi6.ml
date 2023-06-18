
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

let append_right a b = 
  fold_right (fun a list -> a::list) a b;;

let rec append_to_end_sub list a res =
  match list with
  | [] -> a :: res
  | _ -> append_to_end_sub (get_until_nth  ((list_len list) - 1) list) (get_right list) (a :: res);;

let append_to_end list a = append_to_end_sub list a [];;

let append_left a b=
  fold_left append_to_end a b;;

let filter_right f a =
  fold_right (fun b list -> if (f b) then (b::list) else list) a [];;

let filter_left f a=
  fold_left (fun list b -> if (f b) then (append_to_end list b) else list) [] a;;