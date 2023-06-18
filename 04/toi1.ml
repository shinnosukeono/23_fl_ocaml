type 'a m = ('a, string) result

let (>>=) (x : 'a m) (f : 'a -> 'b m) : 'b m =
  match x with
  | Ok(v) -> f v
  | Error msg -> Error msg

let return (x : 'a) : 'a m = Ok x

let (let*) = (>>=)

let err msg = Error msg

let myDiv x y : int m =
  if y = 0 then
    Error "Division by Zero"
  else
    return (x / y)

let rec eLookup (key : 'a)  (t : ('a * 'b) list) : 'b m = 
  match t with
  | [] -> err "Not found"
  | (a, b) :: c -> if key = a then return b else eLookup key c (* Write Here *)

let lookupDiv (kx : 'a) (ky : 'a) (t : ('a * int) list) : int m = 
  let* x = eLookup kx t in
  let* y = eLookup ky t in
  let* z = myDiv x y in
  return z (* Write Here *)

(** Tests *)
let table = [("x", 6); ("y", 0); ("z", 2)]

(* same as is_error *)
let isErr x =
  match x with
  | Ok(_) -> false
  | Error(_) -> true

let () =
  let b1 = isErr (lookupDiv "x" "y" table) in
  let b2 = (Ok 3 = lookupDiv "x" "z" table) in
  let b3 = isErr (lookupDiv "x" "a" table) in
  let b4 = isErr (lookupDiv "a" "z" table) in
  if b1 && b2 && b3 && b4 then
    print_string "ok\n"
  else
    print_string "wrong\n"
