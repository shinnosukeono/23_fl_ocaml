open Syntax

exception Unbound

type env = (name * value) list

let empty_env = []
let extend x v env = (x, v) :: env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

exception EvalErr

let rec eval_expr env e =
  match e with
  | EConstInt i ->
      VInt i
  | EConstBool b ->
      VBool b
  | EVar x ->
      (try
         lookup x env
       with
       | Unbound -> raise EvalErr)
  | EAdd (e1,e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VInt i1, VInt i2 -> VInt (i1 + i2)
       | _ -> raise EvalErr)
  | ESub (e1,e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VInt i1, VInt i2 -> VInt (i1 - i2)
       | _ -> raise EvalErr)
  | EMul (e1,e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VInt i1, VInt i2 -> VInt (i1 * i2)
       | _ -> raise EvalErr)
  | EDiv (e1,e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VInt i1, VInt i2 -> VInt (i1 / i2)
       | _ -> raise EvalErr)
  | EEq (e1,e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VInt i1,  VInt i2  -> VBool (i1 = i2)
       | _ -> raise EvalErr)
  | ELt (e1,e2) ->
      let v1 = eval_expr env e1 in
      let v2 = eval_expr env e2 in
      (match v1, v2 with
       | VInt i1,  VInt i2  -> VBool (i1 < i2)
       | _ -> raise EvalErr)
  | EIf (e1,e2,e3) ->
      let v1 = eval_expr env e1 in
      (match v1 with
       | VBool b ->
           if b then eval_expr env e2 else eval_expr env e3
       | _ -> raise EvalErr)
  | ELet (e1,e2,e3) ->
    let v2 = eval_expr env e2 in
    let newenv = extend e1 v2 env in
    eval_expr newenv e3
  | ELetRec (decls, e) ->
    let oenv = ref [] in
      List.iter(fun (f, x, e) -> let v = VRecFun(x, e, oenv) in oenv := (f, v) :: !oenv) decls;
      oenv := !oenv @ env;
      eval_expr !oenv e
  | EFun (x, e) -> VFun (x, e, env)
  | EApp (e1, e2) ->
    let v1 = eval_expr env e1 in
    let v2 = eval_expr env e2 in
    (match v1 with
      | VFun(x, e, oenv) ->
          eval_expr (extend x v2 oenv) e
      | VRecFun(x, e, oenv) ->
          eval_expr (extend x v2 !oenv) e
      | _ -> raise EvalErr)
    
exception DeclareErr

let eval_command env c =
  match c with
  | CExp e -> (["-"], env, [eval_expr env e])
  | CDecl (e1, e2) ->
    let v1 = eval_expr env e2 in
    ([e1], extend e1 v1 env, [v1])
  | CRecDecl decls ->
    let oenv = ref [] in
    List.iter(fun (f, x, e) -> let v = VRecFun(x, e, oenv) in oenv := (f, v) :: !oenv) decls;
    oenv := !oenv @ env;
    let f_list = List.rev_map(fun (f, _, _) -> f) decls in
    let v_list = List.rev_map(fun (_, x, e) -> VFun(x, e, !oenv)) decls in  
    (f_list, !oenv, v_list)