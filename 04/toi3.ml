type 'a m = 'a * string

let (>>=) (x : 'a m) (f : 'a -> 'b m) : 'b m = 
  let (a, w1) = x in
  let (b, w2) = f a in
  (b, w1 ^ w2)(* Write Here *)

let return (x : 'a) : 'a m = (x, "")(* Write Here *)

let (let*) = (>>=)

let writer (m : string) : unit m = ((), m)

let msg n = ("Fib(" ^ (string_of_int n) ^")\n")

let rec fib n : int m =
  let* _ = writer (msg n) in
  if n <= 1 then
    return n
  else
    let* x = fib (n-2) in
    let* y = fib (n-1) in
    return (x + y)

let () =
  let (_, m) = fib 4 in

  print_string m
(** Expected Output:
  Fib(4)
  Fib(2)
  Fib(0)
  Fib(1)
  Fib(3)
  Fib(1)
  Fib(2)
  Fib(0)
  Fib(1)
 *)
