let buf = ref 0
let f x =
  let tmp = !buf in
    (buf := x; tmp);;