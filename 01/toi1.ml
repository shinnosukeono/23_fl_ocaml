let rec sum_to n =
  match n with
  | 0 -> 0
  | n -> n + sum_to (n - 1);;

let rec check x d =
  match d with
  | 1 -> true
  | _ -> (x mod d <> 0) && check x (d - 1);;

let is_prime n =
  match n with
  | 1 -> false
  | _ -> check n (n - 1);;

let rec gcd x y =
  if y = 0 then
    x
  else
    gcd y (x mod y);;