let twice f = (fun x -> f (f x));;

let rec repeat f n =
  match n with
  | 1 -> (fun x -> f x)
  | m -> (fun x -> (f (repeat f (n - 1) x)));;