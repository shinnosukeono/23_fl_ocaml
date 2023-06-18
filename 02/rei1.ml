type complex =
  {re: float; im: float};;

let prod z1 z2 =
  {re = z1.re *. z2.re -. z1.im *. z2.im; im = z1.re *. z2.im +. z2.re *. z1.im};;

type str_tree =
  | Leaf
  | Node of string * str_tree * str_tree;;

let st1 = Node("hello", Node("this", Leaf, Leaf), Leaf);;

type ib_list =
  INil
  | ICons of int * bi_list
and bi_list =
  BNil
  | BCons of bool * ib_list;;

let ib1 = ICons (3, BCons (false, INil));;