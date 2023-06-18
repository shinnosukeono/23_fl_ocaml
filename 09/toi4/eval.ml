open Syntax

exception Unbound

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
        let thunk = lookup x env in
          match thunk with Thunk(expr, env') ->
            eval_expr env' expr
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
    let newenv = extend e1 (Thunk(e2,env)) env in
    eval_expr newenv e3
  | ELetRec (f, x, e1, e2) ->
    let env' =
      extend f (Thunk(ERecFun(f, x, e1),env)) env in
      eval_expr env' e2
  | EFun (x, e) -> VFun (x, e, env)
  | ERecFun (f, x, e) -> VRecFun(f, x, e, env)
  | EApp (e1, e2) ->
    let v1 = eval_expr env e1 in
    (match v1 with
      | VFun(x, e, oenv) ->
        let thunk = Thunk(e2, env) in
          eval_expr (extend x thunk oenv) e
      | VRecFun (f, x, e, oenv) ->
        let env' =
          extend x (Thunk(e2, env)) (extend f (Thunk(ERecFun(f,x,e), oenv)) oenv) in
          eval_expr env' e
      | _ -> raise EvalErr)

exception DeclareErr

let eval_command env c =
  match c with
  | CExp e -> ("-", env, eval_expr env e)
  | CDecl (e1, e2) ->
    let v1 = eval_expr env e2 in
    (e1, extend e1 ((Thunk(e2, env))) env, v1)
  | CRecDecl (e1, e2, e3) ->
    let v1 = VRecFun(e1, e2, e3, env) in
    let env' = extend e1 (Thunk(ERecFun(e1, e2, e3), env)) env in
      (e1, env', v1)