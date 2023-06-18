type 'a m = int -> ('a * int)

let (>>=) (x : 'a m) (f : 'a -> 'b m) : 'b m =
  fun s ->
    let (a, s') = x s in
    f a s'

let return (x : 'a) : 'a m =
  fun s -> (x, s)

let (let*) = (>>=)

let cache_list = ref []

let rec search n list =
  match list with
  | x::xs -> let (key, value) = x in if n = key then value else search n xs
  | [] -> None


let memo (f : int -> int m) (n : int) : int m =
  fun s ->
    let x = search n !cache_list in
    match x with
    | Some value -> (value, s)
    | None ->
      let (x, s') = f n s in
      cache_list := (n, Some x) :: !cache_list;
      (x, s')

let runMemo (x : 'a m) : 'a =let (a, _) = x 0 in a


let rec fib n =
  if n <= 1 then
    return n
  else
    let* r1 = memo fib (n-2) in
    let* r2 = memo fib (n-1) in
    return (r1 + r2)

let () =
  if runMemo (fib 80) = 23416728348467685 && runMemo (fib 10) = 55 then
    print_string "ok\n"
  else
    print_string "wrong\n"
