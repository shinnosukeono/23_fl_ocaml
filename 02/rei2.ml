type iexpr =
  | EConstant of int
  | EAdd of iexpr * iexpr
  | ESub of iexpr * iexpr
  | EMul of iexpr * iexpr;;

let rec eval x =
  match x with
  | EConstant n -> n
  | EAdd (a, b) -> eval a + eval b
  | ESub (a, b) -> eval a - eval b
  | EMul (a, b) -> eval a * eval b;;
