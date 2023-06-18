exception TyError

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

type constraints = (ty * ty) list
type subst = (tyvar * ty) list

let rec ty_lookup subst tyvar =
	match subst with
	| [] -> TyVar (tyvar)
	| (tyvar_key,t)::subst'-> if tyvar = tyvar_key then t else (ty_lookup subst' tyvar)

let rec ty_subst subst ty =
	match ty with
	| TyInt -> TyInt
	| TyBool -> TyBool
	| TyFun (t1,t2) -> 
					 TyFun((ty_subst subst t1),(ty_subst subst t2))
	| TyVar (tyvar) -> 
					 (ty_lookup subst tyvar)

let rec ty_update old_ty new_ty ty=
  match ty with
  | x when x = old_ty -> new_ty
  | TyFun (t1,t2) -> TyFun ((ty_update old_ty new_ty t1), (ty_update old_ty new_ty t2))
  | _ -> ty

let rec subst_update old_ty new_ty subst =
  match subst with
  |[] -> []
  |(t1,t2)::subst' ->((t1,(ty_update old_ty new_ty t2))::(subst_update old_ty new_ty subst'))
  
let rec compose subst_f subst_g =
  match subst_f with
  |[] -> subst_g
  |(tyvar,ty)::subst ->
    match ty with
    |TyInt | TyBool | TyFun(_,_) -> 
      (tyvar,ty)::(compose (subst_update (TyVar(tyvar)) ty subst_g) (subst_update (TyVar(tyvar)) ty subst))
    |TyVar(tyvarf) -> 
      (tyvar,(ty_update (TyVar(tyvar)) ty (ty_lookup subst_g tyvarf)))::(compose (subst_update (TyVar(tyvar)) ty subst_g) subst)

let rec occur_check a ty =
  match ty with
  | TyVar(i) when i = a -> 
    print_type ty;
    raise TyError
  | TyFun(t1,t2) -> TyFun((occur_check a t1),(occur_check a t2))
  |_ -> ty

let rec update old_ty new_ty constraints =
  match constraints with
  |[] -> []
  |(t1,t2)::constraints' ->
    (((ty_update old_ty new_ty t1),(ty_update old_ty new_ty t2))::(update old_ty new_ty constraints'))
        
let rec unify constraints =
  match constraints with
  |[] -> []
  |(ty1,ty2)::constraints'->
    (match ty1,ty2 with
      | TyInt,TyInt | TyBool,TyBool -> (unify constraints')
      | (TyFun(t11,t12),TyFun(t21,t22)) -> (unify ([(t11,t21);(t12,t22)] @ constraints'))
      | (ty,TyVar(tyvar))| (TyVar(tyvar),ty) ->
        if (TyVar(tyvar)) = ty
          then (unify constraints')
        else
          (let tty = (occur_check tyvar ty) in (compose [(tyvar,tty)] (unify (update (TyVar(tyvar)) tty constraints')) ))
      | _,_ ->raise TyError)
      
      
      