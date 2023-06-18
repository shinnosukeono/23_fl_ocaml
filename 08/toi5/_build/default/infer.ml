open Syntax
open ConstraintSolver
open TySyntax

exception Unbound

let empty_env = []
let extend x v env = (x, v) :: env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

exception InferErr

let rec infer_expr tyenv e =
  match e with
  | EConstInt _ ->
    (([],TyInt),[])
  | EConstBool _ ->
    (([],TyBool),[])
  | EVar x ->
    (try
       let tysch = lookup x tyenv in ((generalize tyenv (instantiate tysch)), [])
     with
     | Unbound -> raise InferErr)
  | EAdd (e1,e2) | ESub (e1,e2) | EMul (e1,e2) | EDiv (e1,e2) ->(
    let ((l1,t1),c1) = infer_expr tyenv e1 in
    let ((l2,t2),c2) = infer_expr tyenv e2 in
      ((l1@l2,TyInt),[(t1,TyInt);(t2,TyInt)]@c1@c2))
  | EEq(e1,e2) |ELt(e1,e2) ->(
    let ((l1,t1),c1) = infer_expr tyenv e1 in
    let ((l2,t2),c2) = infer_expr tyenv e2 in
      ((l1@l2,TyBool),[(t1,t2)] @ c1 @ c2))
  | EIf (e1,e2,e3) ->(
    let ((l1,t1),c1) = infer_expr tyenv e1 in
    let ((l2,t2),c2) = infer_expr tyenv e2 in
    let ((l3,t3),c3) = infer_expr tyenv e3 in
      ((l1@l2@l3,t2),[(t1,TyBool);(t2,t3)]@c1@c2@c3))
  | ELet (x,e1,e2) -> (
    let ((l1,t1),c1) = infer_expr tyenv e1 in
    let ((l2,t2),c2) = infer_expr (extend x (generalize tyenv t1) tyenv) e2 in
      ((l1@l2,t2),c1@c2))
  | EFun (x,e) ->
    let a = TyVar(new_tyvar ()) in
    let ((l,t),c) = infer_expr (extend x ([],a) tyenv) e in
      ((l,TyFun(a,t)),c)
  | EApp (e1,e2) -> (
    let ((_,t1),c1) = infer_expr tyenv e1 in
    let ((l2,t2),c2) = infer_expr tyenv e2 in
    let a = TyVar(new_tyvar ()) in
      ((l2,a),[(t1,TyFun(t2,a))]@c1@c2))
  | ELetRec (f,x,e1,e2) ->
    let a = TyVar(new_tyvar ()) in
    let b = TyVar(new_tyvar ()) in
    let ((l1,t1),c1) = infer_expr ([(f,([],TyFun(a,b)));(x,([],a))]@tyenv) e1 in
    let sigma = unify c1 in
    let s1 = ty_subst sigma a in
    let ((l2,t2),c2) = infer_expr (extend f (generalize tyenv (TyFun(s1,t1))) tyenv) e2 in
      ((l1@l2,t2),(t1,b)::c1@c2)

let rec infer_command tyenv cmd =
  try
  match cmd with
  | CExp e ->
        let ((_,t),c) = infer_expr tyenv e in
        let te = ty_subst (unify c) t in
        (te, tyenv)
  | CDecl (x,e) ->
        let ((_,t),c) = infer_expr tyenv e in
        let tx = ty_subst (unify c) t in
        (tx, (extend x (generalize tyenv tx) tyenv))
  | CRecDecl (f,x,e) ->
        let a = TyVar(new_tyvar ()) in
        let b = TyVar(new_tyvar ()) in
        let ((_,t),c) = infer_expr ([(f,([],TyFun(a,b)));(x,([],a))]@tyenv) e in
        let ft = ty_subst (unify c) (TyFun(a,t)) in
        (ft, (extend f (generalize tyenv ft) tyenv))
  with TyError ->
    raise InferErr
