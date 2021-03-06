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
%token LT GT LEQ GEQ EQ NEQ
%token INT BOOL VOID
%token TRUE FALSE
%token NOT "!"
%token IF ELSE WHILE
%token PUTCHAR
%token RETURN
%token EOF
%token MINUS_U

%left LT LEQ GT GEQ EQ NEQ
%left PLUS  MINUS
%left TIMES IDENT
%nonassoc MINUS_U
%nonassoc NOT
%left L_PAR

%start prog
%type <SyntaxeAbstr.prog> prog

%%

(* programme est compose d'une premiere partie de var globales et suivi de declarations de fonctions puis fin fichier*)
(*sinon error*)
prog:
| gl=globals fs=list(fun_def) EOF 
	{
	{globals=List.rev gl;functions=fs}
	}
	 
| error
		{ let pos = $startpos in
			let message = Printf.sprintf
				"ERREUR: Grammaire - Echec à la position: %d, %d"
				pos.pos_lnum
				(pos.pos_cnum - pos.pos_bol)
			in
			failwith message }
;

(*types variables ds () d'une fonction: type + identifiant*)
param:
| t = typesVar i=IDENT {i,t}
;

;
(*regle pour les fonctions : types + identifiant  + ( + parametre + ) + { + sequence + } *)
fun_def:
| t = typesFonctions i = IDENT L_PAR ps = separated_list(COMMA,param) R_PAR 
	L_ACC l =globals s = list(instr) R_ACC 
	{
		{name=i;params=ps;return=t;locals=l; code = s}
	} 
;

globals:
| g1 = globals g2 = global {g2::g1}
| {[]}
;
(*valeur globales d'un programme *)
global:
(*cas sans value : initialise un int a 0 et un bool a false*)
| t = typesVar i = IDENT "=" e = expr ";" {(i,t,e)}
| INT i = IDENT ";" {(i,Int, Cst 0)}
| BOOL i = IDENT ";" {(i,Bool,CreaBool false)}
(*
| INT i=IDENT SEMICOLON {Printf.printf "global int sans valeur\n" ;(i,Int)}
| BOOL i=IDENT SEMICOLON {Printf.printf "global false\n"; (i,Bool)}
(*cas avec valeur*)
| INT i=IDENT "="  expr SEMICOLON {(i,Int)}
| BOOL i=IDENT "=" expr  SEMICOLON {(i,Bool)} *)
;

expr:
(*constante*)
| n = CONST
	{Cst n}
| TRUE {CreaBool true}
| FALSE {CreaBool false}
(*Opération binaire*)
| e1=expr op=binop e2=expr
	{Binop(op,e1,e2)}
| "(" e = expr ")" 
	{e}
(* acces variable *)
| id=IDENT
	{Get(id)}
(*appel fonction *)
| id=IDENT "(" e = separated_list(COMMA,expr) ")"						 
	{Call(id,e)}
(*Negation*)
| "!" e = expr
	{Not(e)}
| "-" e = expr {Binop(Mul,e,Cst (-1))} %prec MINUS_U
;

instr:
(*affichage*)
| PUTCHAR L_PAR e=expr R_PAR ";"
	{Putchar(e)}
(*if*)
| id=IDENT "=" e=expr ";"
	{Set(id,e)}
| IF "(" e1=expr ")" "{" seq1=list(instr) "}" ELSE "{" seq2=list(instr) "}"
	{If(e1,seq1,seq2)}
(*while*)
| WHILE "(" e=expr ")" "{" s = list(instr) "}"
	{While(e,s)}
(*return*)
| RETURN e=expr ";"
	{Return e}
(*expression simple*)
| e=expr
	{Expr e}
;

%inline binop:
| PLUS {Add}
| MINUS {Sub}
| TIMES {Mul}
| LT {Lt}
| GT {Lt}
| LEQ {Lt}
| GEQ {Lt}
| EQ {Eq}
| NEQ {Neq}
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
