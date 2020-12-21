open SyntaxeAbstr
open Printf

(*aide affichage*)
let typeToString t = 
  match t with
  | Int -> "INT"
  | Bool -> "BOOL"
  | Void -> "VOID"
;;

let opToString t = 
  match t with
  | Add -> "+"
  | Sub-> "-"
  | Mul -> "*"
  | Lt -> "<"
  | Gt -> ">"
  | Leq -> "<="
  | Geq -> ">="
;;


let rec afficheGlo gg =
	match gg with 
	| [] -> printf "\n"
	| (nom,t)::tl -> printf "%s %s \n" (typeToString t) nom; afficheGlo tl         
;;

let rec affichePara para = 
	match para with 
	| [] -> printf ") {\n"
	| (nom,t)::tl -> printf "%s %s " (typeToString t) nom; affichePara tl 
;;

let rec afficheLocal para = 
	match para with 
	| [] -> printf "\n"
      	| (nom,t)::tl -> printf "\t %s %s \n" (typeToString t) nom; afficheLocal tl 
;;

(*Affichage expr*)
let rec afficheExpr expr =
	match expr with 
	|Cst n -> printf "CST %d " n;
	|Get i -> printf "%s " i;
	|Call (nom,l) -> printf "CST  "; (*afaire*)
	|Binop(op,e1,e2) -> printf "e1 "; printf "%s " (opToString op) ; printf " e2"; (*a faire*)
	|Not(e) -> printf "no "; afficheExpr e 
  
;;
	
(*Affichage instr*)
let rec afficheInstr instr=
	match instr with 
	| Putchar(e) -> printf "PUTCHAR e" ; printf "=>  ("; afficheExpr e ; printf ")";
	| _ -> printf "CST  "; (* afaire*)
	
;;


let rec afficheSeq seq=
	match seq with 
	| [] -> printf "\n"
	| hd::tl -> afficheInstr hd; afficheSeq tl;
;;

(*cas fun_def*)
let rec afficheUneFun ff = 
	printf "%s %s ( " (typeToString ff.return) ff.name; 
	affichePara ff.params;
	afficheLocal ff.locals;				
	afficheSeq ff.code;
	printf "}";
;;

let affichageArbre prog =
	(*cas variables globales*)
	afficheGlo prog.globals; 
	
	let rec afficheFun listFun = 
		match listFun with 
		| [] -> printf "\n"
	        | hd::tl -> afficheUneFun hd; printf "\n\n"; afficheFun tl
	in
	afficheFun prog.functions;
;;
