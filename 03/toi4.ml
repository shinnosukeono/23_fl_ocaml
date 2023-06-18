type order = LT | EQ | GT

exception Not_found;;

module type ORDERED_TYPE =
sig
  type t
  val compare : t -> t -> order
end

module StringKey=
struct
  type t = string
  let compare x y =
    let r = Stdlib.compare x y in
      if      r > 0 then GT
      else if r < 0 then LT
      else               EQ
end

module type MAP =
  functor (T: ORDERED_TYPE) ->
    sig
      val empty : (T.t * 'a) list
      val add : (T.t * 'a) -> (T.t * 'a) list -> (T.t * 'a) list
      val remove : T.t -> (T.t * 'a) list -> (T.t * 'a) list
      val lookup : T.t -> (T.t * 'a) list -> (T.t * 'a)
  end

module MakeMap : MAP=
  functor (T: ORDERED_TYPE) ->
    struct
      let empty = []
      let rec add a list = 
        match list with
        | [] -> [a]
        | x::xs ->
          (let a1, a2 = a in
            let x1, x2 = x in
            match T.compare a1 x1 with
	          | LT -> a :: x :: xs
	          | EQ -> a :: x :: xs
	          | GT -> x :: add a xs)
      let rec remove a list =
        match list with
        | [] -> empty
        | x::xs -> 
          (let x1, x2 = x in
            match T.compare a x1 with
            | LT -> x :: xs
            | EQ -> xs
            | GT -> x :: remove a xs)
      let rec lookup a list = 
        match list with
        | [] -> raise Not_found
        | x::xs -> 
          (let x1, x2 = x in
              match T.compare a x1 with
            | LT -> raise Not_found
            | EQ -> x
            | GT -> lookup a xs)
    end

module StringMap =
    MakeMap (StringKey)