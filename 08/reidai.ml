type tyvar = int (* Write here *)

type ty =
  | TyInt
  | TyBool
  | TyFun of ty * ty
  | TyVar of tyvar

let type_gen = ref 0

let new_tyvar () = (
  type_gen := !type_gen + 1;
  !type_gen
  )
  (* Write here *)

let rec print_type ty = 
  match ty with
  | TyInt -> print_string "int"
  | TyBool -> print_string "bool"
  | TyFun (t1, t2) -> 
    print_string "(";
    print_type t1;
    print_string " -> ";
    print_type t2;
    print_string ")"
  | TyVar (x) -> print_string ("a" ^ (string_of_int x))(* Write here *)
