open Syntax
open Eval

let rec read_eval_print env =
  print_string "# ";
  flush stdout;
  let cmd = Parser.toplevel Lexer.main (Lexing.from_channel stdin) in
  let (id_list, newenv, v_list) = eval_command env cmd in
  List.iter2 (fun id v -> Printf.printf "%s = " id;
  print_value v;
  print_newline ()) id_list v_list;
  read_eval_print newenv

let initial_env =
  empty_env
  |> extend "i" (VInt 1)
  |> extend "v" (VInt 5)
  |> extend "x" (VInt 10)

let _ = read_eval_print initial_env
