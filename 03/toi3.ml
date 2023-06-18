type order = LT | EQ | GT

module type ORDERED_TYPE =
sig
  type t
  val compare : t -> t -> order
end

module OrderedString=
struct
  type t = string
  let compare x y =
    let r = Stdlib.compare x y in
      if      r > 0 then GT
      else if r < 0 then LT
      else               EQ
end

module OrderedInt=
struct
  type t = int
  let compare x y =
    let r = x - y in
      if      r > 0 then GT
      else if r < 0 then LT
      else               EQ
end

module type MULTISET2 =
  functor (T : ORDERED_TYPE) ->
    sig
      type t
      val empty : t
      val add    : T.t -> t -> t
      val remove : T.t -> t -> t
      val count  : T.t -> t -> int
    end

type 'a tree =
    | Leaf
    | Node of 'a * 'a tree * 'a tree * int

exception Not_found

module AbstMultiset2 : MULTISET2 =
    functor (T: ORDERED_TYPE) -> struct
      type t = T.t tree
      let empty = Leaf
      let rec add v tr =
        match tr with
        | Leaf -> Node (v, Leaf, Leaf, 1)
        | Node (n, t1, t2, c) ->
          (match T.compare n v with
            | EQ -> Node (n, t1, t2, c + 1)
            | LT -> Node (n, t1, add v t2, c)
            | GT -> Node (n, add v t1, t2, c))
      let rec remove v tr =
        match tr with
        | Leaf -> raise Not_found
        | Node (n, t1, t2, c) ->
          (match T.compare n v with
            | EQ ->
              (match t1, t2 with
                | Leaf, Leaf -> Leaf
                | _, Leaf -> t1
                | Leaf, _ -> t2
                | _, _ ->
                  let rec min tr =
                    match tr with
                    | Leaf -> raise Not_found
                    | Node (n, Leaf, t2, c) -> n, c
                    | Node (n, t1, t2, c) -> min t1
                  in 
                  let m, cnt = min t2 in
                  Node (m, t1, remove m t2, cnt))
            | LT -> Node (n, t1, remove v t2, c)
            | GT -> Node (n, remove v t1, t2, c))
      let rec count v tr =
        match tr with
        | Leaf -> 0
        | Node (n, t1, t2, c) ->
          (match T.compare n v with
            | EQ -> c
            | LT -> count v t2
            | GT -> count v t1)
    end

module IntMultiset =
  AbstMultiset2 (OrderedInt)
  