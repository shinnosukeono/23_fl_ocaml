open Syntax
exception TyError

type tyvar = Var of int (* Write here *)

type ty =
  | TyInt
  | TyBool
  | TyFun of ty * ty
  | TyVar of tyvar

type type_schema = TyScheme of (tyvar list) * ty

type constraints = (tyvar * type_schema) list
type tyenv = (name * type_schema) list