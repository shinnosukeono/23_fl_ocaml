type 'a m = 'a list

let (>>=) (x : 'a m) (f : 'a -> 'b m) : 'b m =
  List.concat (List.map f x)

let return (x : 'a) : 'a m = [x]

let (let*) = (>>=)

let guard (x : bool) : unit m =
  if x then return () else []

(** check if "banana + banana = sinamon" *)
let test_banana ba na si mo n =
  (100 * ba + 10 * na + na
   + 100 * ba + 10 * na + na
   = 1000 * si + 100 * na + 10 * mo + n)

(** check if "send + more = money" *)
let test_money s e n d m o r y =
  (1000 * s + 100 * e + 10 * n + d
  + 1000 * m + 100 * o + 10 * r + e
  = 10000 * m + 1000 * o + 100 * n + 10 * e + y)
  
let alphametic_banana =
  let* ba = [1;2;3;4;5;6;7;8;9;0] in
  let* na = [1;2;3;4;5;6;7;8;9;0] in
  let* si = [1;2;3;4;5;6;7;8;9;0] in
  let* mo = [1;2;3;4;5;6;7;8;9;0] in
  let* n = [1;2;3;4;5;6;7;8;9;0] in
  let* _ = guard (ba <> 0 && si <> 0 && test_banana ba na si mo n) in
    return (ba, na, si, mo, n)

let rec find n list =
  match list with
  | [] -> false
  | x::xs -> if n = x then true else find n xs

let rec exclude acc ex_list =
  match acc with
  | 10 -> []
  | _ -> if find acc ex_list then exclude (acc+1) ex_list else acc::(exclude (acc+1) ex_list)

let alphametic_money =
  exclude 0 [0] >>= fun s ->
  exclude 0 [s] >>= fun e ->
  exclude 0 [s; e] >>= fun n ->
  exclude 0 [s; e; n] >>= fun d ->
  exclude 0 [s; e; n; d; 0] >>= fun m ->
  exclude 0 [s; e; n; d; m] >>= fun o ->
  exclude 0 [s; e; n; d; m; o] >>= fun r ->
  exclude 0 [s; e; n; d; m; o; r] >>= fun y ->
  guard (test_money s e n d m o r y) >>= fun _ -> return (s, e, n, d, m, o, r, y)