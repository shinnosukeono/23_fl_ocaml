open Syntax

exception Unbound

type env = (name * value) list

let empty_env = []
let extend x v env = (x, v) :: env

let lookup x env =
  try List.assoc x env with Not_found -> raise Unbound

exception EvalErr

let rec check_list_type v1 v2 = 
  match v1 with
  | VInt _ ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> (match v1' with VInt _ -> true |_-> false) && check_list_type v1' v2'
     | _ -> false)
  | VBool _ ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> (match v1' with VBool _ -> true |_-> false) && check_list_type v1' v2'
     | _ -> false)
  | VFun _ ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> (match v1' with VFun _ -> true |_-> false) && check_list_type v1' v2'
     | _ -> false)
  | VRecFun _ ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> (match v1' with VRecFun _ -> true |_-> false) && check_list_type v1' v2'
     | _ -> false)
  | VPair _ ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> (match v1' with VPair _ -> true |_-> false) && check_list_type v1' v2'
     | _ -> false)
  | VNil ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> v1' == VNil && check_list_type v1' v2'
     | _ -> false)
  | VCons _ ->
    (match v2 with
     | VNil -> true
     | VCons (v1', v2') -> (match v1' with VCons _ -> true |_-> false) && check_list_type v1' v2'
     | _ -> false)

let rec find_match pattern value =
  match pattern with
  | PInt(n) -> 
    (match value with
    | VInt(m) -> if n==m then Some([]) else None
    | _ -> None)
  | PBool(p) ->
    (match value with
    | VBool(q) -> if p==q then Some([]) else None
    | _ -> None)
  | PVar(name) -> Some([(name,value)])
  | PPair(p1,p2) ->
    (match value with
    | VPair(q1,q2) -> 
      let l1 = find_match p1 q1 in
      let l2 = find_match p2 q2 in
      if l1 <> None && l2 <> None then
        (match l1 with Some(l1') -> (match l2 with Some(l2') -> Some(l1'@l2')))
      else None
    | _ -> None)
  | PNil ->
    (match value with
    | VNil -> Some([])
    | _ -> None)
  | PCons(p1,p2) ->
    (match value with
    | VCons(q1,q2) -> 
      let l1 = find_match p1 q1 in
      let l2 = find_match p2 q2 in
      if l1 <> None && l2 <> None then
        (match l1 with Some(l1') -> (match l2 with Some(l2') -> Some(l1'@l2')))
      else None
    | _ -> None)


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
  | ELetRec (f, x, e1, e2) ->
    let env' =
      extend f (VRecFun(f, x, e1, env)) env in
      eval_expr env' e2
  | EFun (x, e) -> VFun (x, e, env)
  | EApp (e1, e2) ->
    let v1 = eval_expr env e1 in
    let v2 = eval_expr env e2 in
    (match v1 with
      | VFun(x, e, oenv) ->
          eval_expr (extend x v2 oenv) e
      | VRecFun (f, x, e, oenv) ->
          let env' =
            extend x v2 (extend f (VRecFun(f, x, e, oenv)) oenv) in
            eval_expr env' e
      | _ -> raise EvalErr)
  | EPair(p1,p2) ->
    let v1 = eval_expr env p1 in
    let v2 = eval_expr env p2 in
    VPair (v1,v2)
  | ENil -> VNil
  | ECons(p1,p2) ->
    let v1 = eval_expr env p1 in
    let v2 = eval_expr env p2 in
    if check_list_type v1 v2 then VCons (v1, v2) else raise EvalErr
  | EMatch(e,p_e_list) ->
    let v = eval_expr env e in
    let rec search_patterns value p_e_list = (
      match p_e_list with
      | [] -> raise EvalErr
      | (pattern,expr)::p_e_list' ->
        let n_v_list = find_match pattern value in (
          match n_v_list with
          | Some([]) -> eval_expr env expr
          | Some(list) ->
            let env' = list@env in
            eval_expr env' expr
          | None -> search_patterns value p_e_list'
        )
    ) in
    search_patterns v p_e_list

exception DeclareErr

let eval_command env c =
  match c with
  | CExp e -> ("-", env, eval_expr env e)
  | CDecl (e1, e2) ->
    let v1 = eval_expr env e2 in
    (e1, extend e1 v1 env, v1)
  | CRecDecl (e1, e2, e3) ->
    let v1 = VRecFun(e1, e2, e3, env) in
    let env' = extend e1 v1 env in
      (e1, env', v1)