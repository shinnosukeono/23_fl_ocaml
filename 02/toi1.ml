type nat =
  | Z
  | S of nat;;

let rec add a b =
  match b with
  | Z -> a
  | S c -> S (add a c);;

let sub1 b =
  match b with
  | Z -> Z
  | S c -> c;;

let rec sub a b =
  match a with
  | Z -> Z
  | S c -> if b = (S (Z)) then c else if b = Z then a else sub c (sub1 b);;

let rec mul a b =
  match b with
  | Z -> Z
  | S Z -> a
  | S c -> add a (mul a c);;

let rec pow a b =
  match b with
  | Z -> S Z
  | S Z -> a
  | S c -> mul a (pow a c);;

let rec n2i_sub a n =
  match a with
  | Z -> n
  | S c -> n2i_sub c (n + 1);;

let n2i a = n2i_sub a 0;;

let rec i2n_sub n a =
  match n with
  | 0 -> a
  | _ -> i2n_sub (n - 1) (S a);;

let i2n n = i2n_sub n Z;;