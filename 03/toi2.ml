exception EMPTY
module type STACK =
  sig
    type 'a t
    val pop : 'a t -> ('a * 'a t)
    val push : 'a -> 'a t -> 'a t
    val empty : 'a t
    val size : 'a t -> int
  end

module AbstStack : STACK =
  struct
    type 'a t = 'a list
    let pop a = 
      match a with
      | [] -> raise EMPTY
      | x::xs -> (x, xs)
    let push a b = a::b
    let empty = []
    let rec size_sub a k =
      match a with
      | [] -> k
      | x::xs -> size_sub xs (k+1)
    let size a = size_sub a 0
  end
