let rec list_len_sub list acc =
  match list with
  | [] -> acc
  | x::xs -> list_len_sub xs (acc + 1);;

let list_len list = list_len_sub list 0;;

let rec get_right list=
  match list with
  | x :: [] -> x
  | x::xs -> get_right xs;;

let rec get_first list =
  match list with
  | x::xs -> x;;

let rec remove_first list =
  match list with
  | x::xs -> xs;;

let rec get_until_nth n list =
  if n = 0 then [] else (get_first list) :: (get_until_nth (n - 1) (remove_first list));;

let rec append_to_end_sub list a res =
    match list with
    | [] -> a :: res
    | _ -> append_to_end_sub (get_until_nth  ((list_len list) - 1) list) (get_right list) (a :: res);;
  
let append_to_end list a = append_to_end_sub list a [];;

let rec transpose = function
   | [] 
   | [] :: _ -> []
   | rows    -> 
       List.map List.hd rows :: transpose (List.map List.tl rows)

module type SEMIRING = sig
  type t
  val add : t -> t -> t
  val mul : t -> t -> t
  val unit : t
  val zero : t
end

module BoolSemiring =
  struct
    type t = bool
    let add x y = x || y
    let mul x y = x && y
    let unit = true
    let zero = false
  end

module TropSemiring =
  struct
    type t = int
    let add x y = if x > y then y else x
    let mul x y = x + y
    let unit = 0
    let zero = max_int

  end

exception DIM_ERROR_ADD
exception DIM_ERROR_MUL

module Matrix =
  functor (T: SEMIRING) ->
    struct
      let rec vec_add_sub x y e =
        match x with
        | [] -> 
          (match y with
            | [] -> e
            | _ -> raise DIM_ERROR_ADD)
        | x1::xs -> 
          (match y with
            | [] -> raise DIM_ERROR_ADD
            | y1::ys -> vec_add_sub xs ys (append_to_end e (T.add x1 y1)))
      let vec_add x y = vec_add_sub x y []
      let rec vec_mul_sub x y e=
        match x with
        | [] -> 
          (match y with
            | [] -> e
            | _ -> raise DIM_ERROR_MUL)
        | x1::xs -> 
          (match y with
            | [] -> raise DIM_ERROR_MUL
            | y1::ys -> vec_mul_sub xs ys (T.add e (T.mul x1 y1)))
      let vec_mul x y = vec_mul_sub x y T.zero
      let rec mat_add_sub x y e =
        match x with
        | [] ->
          (match y with
            | [] -> e
            | _ -> raise DIM_ERROR_ADD)
        | x1::xs ->
          (match y with
            | [] -> raise DIM_ERROR_ADD
            | y1::ys -> mat_add_sub xs ys (append_to_end e (vec_add x1 y1)))
      let mat_add x y = mat_add_sub x y []
      let rec vec_mat_mul_sub x y e_v =
        match y with
        | [] -> e_v
        | y1::ys -> vec_mat_mul_sub x ys (append_to_end e_v (vec_mul x y1))
      let vec_mat_mul x y = let y_t = transpose y in vec_mat_mul_sub x y_t []
      let rec mat_mul_sub x y e_m =
        match x with
        | [] -> e_m
        | x1::xs ->
          mat_mul_sub xs y (append_to_end e_m (vec_mat_mul x1 y))
      let mat_mul x y = mat_mul_sub x y []
    end

module BoolMatrix = Matrix (BoolSemiring)

module TropMatrix = Matrix (TropSemiring)