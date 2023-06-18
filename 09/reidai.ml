type name = VName of string

type expr =
  | EConstInt  of int
  | EConstBool of bool
  | EVar       of name
  | EAdd       of expr * expr
  | ESub       of expr * expr
  | EMul       of expr * expr
  | EDiv       of expr * expr
  | EEq        of expr * expr
  | ELt        of expr * expr
  | EIf        of expr * expr * expr
  | ELet       of name * expr * expr
  | EFun       of name * expr
  | EApp       of expr * expr
  | ELetRec    of name * name * expr * expr

type value =
  | VInt of int
  | VBool of bool
  | VFun of name * expr * ((name * value) list)
  | VRecFun of name * name * expr * ((name * value) list)
  | VPair of value * value
  | VNil
  | VCons of value * value

type pattern =
  | PInt of int
  | PBool of bool
  | PVar of name
  | PPair of pattern * pattern
  | PNil
  | PCons of pattern * pattern

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

let rec print_value v =
    match v with
    | VInt i  -> print_int i
    | VBool b -> print_string (string_of_bool b)
    | VFun _ -> print_string "<fun>"
    | VRecFun _ -> print_string "<fun>"
    | VPair (a,b) | VCons (a,b)->
        print_string "(";
        print_value a;
        print_string ",";
        print_value b;
        print_string ")";
    | VNil -> print_string "<nil>"

let rec print_match list =
  match list with
  | None -> print_string "failed"
  | Some([]) -> print_string "patten match to here\n"
  | Some((name,value)::list') ->
    (match name with VName(n_str) -> (
      print_string n_str;
      print_string ":";
      print_value value;
      print_newline ();
      print_match (Some list')))

let check_find_match pattern value =
  let list = find_match pattern value in
  print_match list

