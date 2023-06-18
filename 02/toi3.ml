type 'a tree =
  | Leaf
  | Node of 'a * 'a tree * 'a tree;;

let level_order t =
  let rec level_order_sub queue acc =
    match queue with
    | [] -> acc
    | Leaf :: q -> level_order_sub q acc
    | Node (r, sub1, sub2) :: t -> 
      let new_queue = t @ [sub1; sub2] in
        let new_acc = acc @ [r] in
          level_order_sub new_queue new_acc
    in level_order_sub [t] [];;

let comptree = 
  Node(1, Node(2, Node(4, Leaf, Leaf),
                  Node(5, Leaf, Leaf)),
          Node(3, Node(6, Leaf, Leaf),
                  Node(7, Leaf, Leaf)));;