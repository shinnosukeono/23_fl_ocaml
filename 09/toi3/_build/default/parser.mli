
(* The type of tokens. *)

type token = 
  | WITH
  | TIMES
  | THEN
  | SEMISEMI
  | RPAR
  | REC
  | RBRACKET
  | PLUS
  | MINUS
  | MATCH
  | LT
  | LPAR
  | LET
  | LBRACKET
  | INT of (int)
  | IN
  | IF
  | ID of (string)
  | FUN
  | EQ
  | ELSE
  | DIV
  | CONS
  | COMMA
  | BOOL of (bool)
  | BAR
  | ARROW

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val toplevel: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Syntax.command)
