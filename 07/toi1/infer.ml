open Syntax

exception Unbound

let empty_env = []
let extend x v env = (x, v) :: env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

exception InferErr

let rec infer_expr tyenv e =
  match e with
  | EConstInt _ ->
    (TySyntax.TyInt,[])
  | EConstBool _ ->
    (TySyntax.TyBool,[])
  | EVar x ->
    (try
       ((lookup x tyenv),[])
     with
     | Unbound -> raise InferErr)
  | EAdd (e1,e2) | ESub (e1,e2) | EMul (e1,e2) | EDiv (e1,e2) ->(
    let (t1,c1) = infer_expr tyenv e1 in
    let (t2,c2) = infer_expr tyenv e2 in
      (TySyntax.TyInt,[(t1,TySyntax.TyInt);(t2,TySyntax.TyInt)] @ c1 @ c2))
  | EEq(e1,e2) |ELt(e1,e2) ->(
    let (t1,c1) = infer_expr tyenv e1 in
    let (t2,c2) = infer_expr tyenv e2 in
      (TySyntax.TyBool,[(t1,t2)] @ c1 @ c2))
  | EIf (e1,e2,e3) ->(
    let (t1,c1) = infer_expr tyenv e1 in
    let (t2,c2) = infer_expr tyenv e2 in
    let (t3,c3) = infer_expr tyenv e3 in
      (t2,[(t1,TySyntax.TyBool);(t2,t3)] @ c1 @ c2 @ c3))
  | ELet (x,e1,e2) -> (
    let (t1,c1) = infer_expr tyenv e1 in
    let (t2,c2) = infer_expr (extend x t1 tyenv) e2 in
      (t2,c1 @ c2))
  | EFun (x,e) ->
    let a = TySyntax.TyVar(TySyntax.new_tyvar ()) in
    let (t,c) = infer_expr (extend x a tyenv) e in
      (TySyntax.TyFun(a,t),c)
  | EApp (e1,e2) -> (
    let (t1,c1) = infer_expr tyenv e1 in
    let (t2,c2) = infer_expr tyenv e2 in
    let a = TySyntax.TyVar(TySyntax.new_tyvar ()) in
      (a,[(t1,TySyntax.TyFun(t2,a))] @ c1 @ c2))
  | ELetRec (f,x,e1,e2) ->
    let a = TySyntax.TyVar(TySyntax.new_tyvar ()) in
    let b = TySyntax.TyVar(TySyntax.new_tyvar ()) in
    let (t1,c1) = infer_expr (extend f (TySyntax.TyFun(a,b)) (extend x a tyenv)) e1 in
    let (t2,c2) = infer_expr (extend f (TySyntax.TyFun(a,b)) tyenv) e2 in
      (t2,(t1,b)::c1 @ c2)

let rec infer_command tyenv cmd =
  try
  match cmd with
  | CExp e ->
        let (t,c) = infer_expr tyenv e in
        let te = ConstraintSolver.ty_subst (ConstraintSolver.unify c) t in
        te, tyenv
  | CDecl (x,e) ->
        let (t,c) = infer_expr tyenv e in
        let tx = ConstraintSolver.ty_subst (ConstraintSolver.unify c) t in
        tx, (extend x tx tyenv)
  | CRecDecl (f,x,e) ->
        let a = TySyntax.TyVar(TySyntax.new_tyvar ()) in
        let b = TySyntax.TyVar(TySyntax.new_tyvar ()) in
        let (t,c) = infer_expr (extend f (TySyntax.TyFun(a,b)) (extend x a tyenv)) e in
        let ft = ConstraintSolver.ty_subst (ConstraintSolver.unify ((t,b)::c)) (TySyntax.TyFun(a,b)) in
        ft, (extend f ft tyenv)
  with ConstraintSolver.TyError ->
    raise InferErr
