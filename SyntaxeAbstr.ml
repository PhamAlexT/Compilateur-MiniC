type typ =
    | Int
    | Bool
    | Void
type binop=
    |Add
    |Sub
    |Mul
    |Lt
    |Gt
    |Leq
    |Geq
    |Eq
    |Neq
type expr =
    | Cst  of int
    | CreaBool of bool
    | Binop  of binop * expr * expr
    | Get  of string
    | Call of string * expr list
    | Not of expr
    
type instr =
    | Putchar of expr
    | Set     of string * expr
    | If      of expr * seq * seq
    | While   of expr * seq
    | Return  of expr
    | Expr    of expr
and seq = instr list

type fun_def = {
    name:   string;
    params: (string * typ) list;
    return: typ;
    locals: (string * typ * expr) list;
    code:   seq;
}

type prog = {
    globals:   (string * typ * expr) list;
    functions: fun_def list;
}




