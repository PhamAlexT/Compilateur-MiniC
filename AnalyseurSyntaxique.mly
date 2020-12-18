%{
open SyntaxeAbstr
%}

%token <int> CONST
%token <string> IDENT
%token SEMICOLON ";"
%token COMMA ","
%token EQUAL "="
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

%nonassoc ELSE

%left PLUS MINUS
%left TIMES
%left L_PAR IDENT INT

%start prog
%type <SyntaxeAbstr.prog> prog

%%

prog:
| gl=list(global) fs=list(fun_def) EOF {{globals=gl;functions=fs}} 
| error
		{ let pos = $startpos in
			let message = Printf.sprintf
				"échec à la position: %d, %d"
				pos.pos_lnum
				(pos.pos_cnum - pos.pos_bol)
			in
			failwith message }
;

param:
| t = typesVar i=IDENT {i,t}
;

global:
| INT i=IDENT EQUAL value = CONST SEMICOLON {i,Int,CreaInt value}
| BOOL i=IDENT EQUAL value = TRUE SEMICOLON {i,Bool,CreaBool true}
| BOOL i=IDENT EQUAL value = FALSE SEMICOLON {i,Bool,CreaBool false}
;

fun_def:
| t = typesFonctions i = IDENT L_PAR ps = separated_list(COMMA,param) R_PAR 
	L_ACC s = list(instr) R_ACC
	{{name=i;params=ps;return=Int;code=s;locals=[]}}
;

expr:
| n = CONST
	{Cst n}
| "(" e = expr ")"
	{e}
| e1=expr "+" e2=expr
	{Add(e1,e2)}
| e1=expr TIMES e2=expr
	{Mul(e1,e2)}
| id=IDENT
	{Get(id)}
| e1 = expr LT e2 = expr 
	{Lt(e1,e2)}
;

instr:
| e=expr
	{Expr e}
| PUTCHAR L_PAR e=expr R_PAR
	{Putchar(e)}
| BOOL s = IDENT EQUAL FALSE ";"
	{Set(s,Cst 0)}
| BOOL s = IDENT EQUAL TRUE ";"
	{Set(s,Cst 1)}
| INT s = IDENT EQUAL e=expr SEMICOLON
	{Set(s,e)}
| IF e1=expr "{" seq1=list(instr) "}" ELSE "{" seq2=list(instr) "}"
	{If(e1,seq1,seq2)}
| WHILE e=expr s = list(instr)
	{While(e,s)}
| RETURN e=expr ";"
	{Return e}
;

%inline comp:
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