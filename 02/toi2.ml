type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree;;

let rec pre_order t=
  match t with
  | Leaf -> []
  | Node (r, sub1, sub2) -> r :: (pre_order sub1)  @ (pre_order sub2);;

let rec in_order t =
  match t with
  | Leaf -> []
  | Node (r, sub1, sub2) -> (in_order sub1) @ (r :: (in_order sub2));;

let rec post_order t =
  match t with
  | Leaf -> []
  | Node (r, sub1, sub2) -> (post_order sub1) @ (post_order sub2) @ [r];;
