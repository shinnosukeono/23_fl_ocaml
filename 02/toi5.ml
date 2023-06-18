type expr =
  | EConstInt of int
  | EAdd of expr * expr
  | ESub of expr * expr
  | EMul of expr * expr
  | EDiv of expr * expr
  | EConstBool of bool
  | EEqual of expr * expr
  | ELT of expr * expr (* false < true *)
  | EIF of expr * expr * expr;;

type value =
  | VInt of int
  | VBool of bool

exception Eval_error;;

let is_int v =
  match v with
  | VInt n -> true
  | VBool b -> false;;

let get_int v = 
  let get_int_sub v =
    match v with
    VInt n -> n
  in if is_int v then get_int_sub v else raise Eval_error;;

let get_bool v =
  let get_bool_sub v =
    match v with
    | VBool b -> b
  in if is_int v then raise Eval_error else get_bool_sub v;;

let get_int_nonzero v =
  let x = get_int v in if x = 0 then raise Eval_error else x;;

let are_same_type a b =
  if (((is_int a) = true) && ((is_int b) = true)) || (((is_int a) = false) && ((is_int b) = false)) then true else false;;

let rec eval e =
  match e with
  | EConstInt n -> VInt n
  | EAdd (a, b) -> VInt (get_int (eval a) + get_int (eval b))
  | ESub (a, b) -> VInt (get_int (eval a) - get_int (eval b))
  | EMul (a, b) -> VInt (get_int (eval a) * get_int (eval b))
  | EDiv (a, b) -> VInt (get_int (eval a) / get_int_nonzero (eval b))
  | EConstBool b -> VBool b
  | EEqual (a, b) -> if are_same_type (eval a) (eval b) then (if (eval a)=(eval b) then VBool true else VBool false) else raise Eval_error
  | ELT (a, b) -> if are_same_type (eval a) (eval b) then (if (eval a)<(eval b) then VBool true else VBool false) else raise Eval_error
  | EIF (a, b, c) -> if is_int (eval a) then raise Eval_error else (if get_bool (eval a) then (eval b) else (eval c));;