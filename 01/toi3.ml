let rec fix f x = f (fix f) x;;

let sum_to_fix =
  fix (fun f n -> if n = 1 then 1 else n + f (n - 1));;

let check_fix =
  fix (fun f n m -> if m = 1 then true else (n mod m <> 0) && f n (m - 1));;

let is_prime_fix n =
  if n = 1 then false else check_fix n (n - 1);;

let gcd_fix =
  fix (fun f n m -> if m = 0 then n else f m (n mod m));;