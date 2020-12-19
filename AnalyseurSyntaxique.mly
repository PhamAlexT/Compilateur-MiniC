%{
open SyntaxeAbstr
%}

%token <int> CONST
%token <string> IDENT
%token SEMICOLON ";"
%token COMMA ","
%token AFF "="
%token PLUS "+" MINUS "-"
%token TIMES
%token L_PAR "(" R_PAR ")"
%token L_ACC "{" R_ACC "}"
%token LT GT LEQ GEQ
%token INT BOOL VOID
%token TRUE FALSE
%token IF ELSE WHILE
%token PUTCHAR
%token RETURN
%token EOF

%left LT LEQ GT GEQ
%left PLUS MINUS
%left TIMES


%start prog
%type <SyntaxeAbstr.prog> prog

%%

(* programme est compose d'une premiere partie de var globales et suivi de declarations de fonctions puis fin fichier*)
(*sinon error*)
prog:
| gl=globals fs=list(fun_def) EOF 
	{
	{globals=gl;functions=fs}
	}
	 
| error
		{ let pos = $startpos in
			let message = Printf.sprintf
				"échec à la position: %d, %d"
				pos.pos_lnum
				(pos.pos_cnum - pos.pos_bol)
			in
			failwith message }
;

(*types variables ds () d'une fonction: type + identifiant*)
param:
| t = typesVar i=IDENT {i,t}
;

(*regle pour les fonctions : types + identifiant  + ( + parametre + ) + { + sequence + } *)
fun_def:
| t = typesFonctions i = IDENT L_PAR ps = separated_list(COMMA,param) R_PAR 
	L_ACC l = globals s = list(instr) R_ACC 
	{
		Printf.printf "Nom fonction: %s\n" i;{name=i;params=ps;return=t;locals=l; code = s}
	} 
;

globals:
| g1 = globals g2 = global {g2::g1}
| {[]}
;
(*valeur globales d'un programme *)
global:
(*cas sans value : initialise un int a 0 et un bool a false*)
| INT i=IDENT SEMICOLON {Printf.printf "global int sans valeur\n" ;(i,Int)}
| BOOL i=IDENT SEMICOLON {Printf.printf "global false\n"; (i,Bool)}
(*cas avec valeur*)
| INT i=IDENT "=" value = CONST SEMICOLON {(i,Int)}
| BOOL i=IDENT "=" value = TRUE  SEMICOLON {(i,Bool)}
| BOOL i=IDENT "=" value = FALSE  SEMICOLON {(i,Bool)}
;

expr:
(*constante*)
| n = CONST
	{Cst n}
(*Opération binaire*)
| e1=expr op=binop e2=expr
	{Binop(op,e1,e2)}
(*appel fonction *)
| id=IDENT "(" e = separated_list(COMMA,expr) ")"  (* pour un appel de fonctions : essai (a, b+c) : identifiant + plusieurs expr qu'on veut mettre en liste chaque expr est separe par une virgule*)								 
	{Call(id,e)} 
(* acces variable *)
| id=IDENT
	{Get(id)}
;

instr:
(*expression simple*)
| e=expr
	{Expr e}
(*affichage*)
| PUTCHAR L_PAR e=expr R_PAR ";"
	{Putchar(e)}
(*var locales*)
| BOOL s = IDENT "=" FALSE ";"
	{Set(s,Cst 0)}
| BOOL s = IDENT "=" TRUE ";"
	{Set(s,Cst 1)}
| INT s = IDENT "=" e=expr SEMICOLON
	{Set(s,e)}
(*if*)
| IF "(" e1=expr ")" "{" seq1=list(instr) "}" ELSE "{" seq2=list(instr) "}"
	{If(e1,seq1,seq2)}
(*while*)
| WHILE "(" e=expr ")" "{" s = list(instr) "}"
	{While(e,s)}
(*return*)
| RETURN e=expr ";"
	{Return e}
;

%inline binop:
| PLUS {Add}
| MINUS {Sub}
| TIMES {Mul}
| LT {Lt}
| GT {Lt}
| LEQ {Lt}
| GEQ {Lt}
;

%inline typesVar:
| INT {Int}
| BOOL {Bool}
;

%inline typesFonctions:
| INT {Int}
| BOOL {Bool}
| VOID {Void}
;
