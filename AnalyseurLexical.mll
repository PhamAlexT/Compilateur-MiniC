{
open Lexing
open AnalyseurSyntaxique
open Printf

let keyword_or_ident =
  let h = Hashtbl.create 17 in
  List.iter
    (fun (s, k) -> Hashtbl.add h s k)
    [
      "int", INT;
      "bool", BOOL;
      "void", VOID;
      "true", TRUE;
      "false", FALSE;
      "if", IF;
      "else", ELSE;
      "while", WHILE;
      "putchar", PUTCHAR;
      "return",RETURN
    ] ;
  fun s ->
    try  Hashtbl.find h s
    with Not_found -> IDENT(s)

let print_token = function
  | PUTCHAR -> printf "PUTCHAR\n"
  | IDENT(s) -> printf "IDENT %s\n" s
  | CONST(n) -> printf "CONST %i\n" n
  | AFF -> printf "AFFECTATION \n"
  | PLUS     -> printf "PLUS\n"
  | MINUS -> printf "MINUS\n"
  | TIMES -> printf "TIMES\n"
  | L_PAR     -> printf "L_PAR\n"
  | R_PAR     -> printf "R_PAR\n"
  | L_ACC -> printf "L_ACC\n"
  | R_ACC ->printf "R_ACC\n"
  | LT -> printf "LESS THAN\n"
  | GT -> printf "GREATER THAN\n"
  | GEQ -> printf "GEQ \n"
  | LEQ -> printf "LEQ \n"
  | EQ -> printf "EQUAL\n"
  | NEQ -> printf "NEQ\n"
  | COMMA -> printf "COMMA \n"
  | SEMICOLON -> printf "SEMICOLON\n"
  | INT -> printf "INT\n"
  | BOOL -> printf "BOOL\n"
  | TRUE -> printf "TRUE\n"
  | FALSE -> printf "FALSE\n"
  | NOT -> printf "NOT\n"
  | VOID -> printf "VOID\n"
  | IF -> printf "IF\n"
  | ELSE ->printf "ELSE\n"
  | WHILE -> printf "WHILE\n"
  | RETURN -> printf "RETURN\n"
  | EOF      -> assert false

let line = ref 1
let col  = ref 0
let space()   = incr col
let tab()     = col := !col+2
let newline() = col := 0; incr line
}


let alpha = ['a'-'z' 'A'-'Z']
let digit =  ['0'-'9'] | '-'['0'-'9']  (*nb positif ou nb negatif*)
let ident = (alpha) (alpha | ['0'-'9'] | '_')*

rule token = parse
                      | ' '    { space(); token lexbuf }
                      | '\n'   { newline(); new_line lexbuf;token lexbuf }
                      | digit+ as s { CONST (int_of_string s) }
                      | ident as s { keyword_or_ident s}
                      | "==" {EQ}
                      | "!=" {NEQ}
                      | '='   { AFF }
                      | '+'    { PLUS }
                      | '-' {MINUS}
                      | '*' {TIMES}
                      | '('    { L_PAR }
                      | ')'    { R_PAR }
                      | '{'	{L_ACC}
                      | '}'	{R_ACC}
                      | '<' {LT}
                      | '>' {GT}
                      | ">=" {GEQ}
                      | "<=" {LEQ}
                      | ';' {SEMICOLON}
                      | ',' {COMMA}
                      | '!' {NOT}
                      | _ as c {	failwith	(sprintf "ERREUR: Caractère illégale : %c Position : Ligne %i, Colonne %i, " c !line !col )}
                      |eof { EOF}
{
let lexbuf = Lexing.from_channel(open_in Sys.argv.(1))

let rec loop () =
  let t = token lexbuf in
  if t <> EOF
  then begin loop () end

let _ =
  loop ()
}
