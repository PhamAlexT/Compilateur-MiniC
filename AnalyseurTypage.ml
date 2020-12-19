open SyntaxeAbstr
(*Hashtbl pour var globales*)
let valGlobales: (string,SyntaxeAbstr.typ ) Hashtbl.t = Hashtbl.create 4;;
(*Hashtbl pour fonctions*)
let infoFunctions : (string,SyntaxeAbstr.fun_def) Hashtbl.t = Hashtbl.create 4;;

let rec creaGlobales  l =
 	match l with
 	| [] -> ()
	| (i , t )::tl ->
		match (Hashtbl.find_opt valGlobales i) with 
		 |None-> Hashtbl.add valGlobales i t;creaGlobales tl
		 |_ -> failwith ("Erreur: 2 variables globales de même nom.");
		;

		Printf.printf "Nombre de variable globales: %d \n" (Hashtbl.length valGlobales)
;;

let rec analyseExpression expr environnement=
	match expr with
	|Cst n -> Int
	|Get i -> Hashtbl.find environnement expr
	|Call (nom,l) -> Int (* To do : Le return de même type? Nombre d'arguments?*)
	|Binop(op,e1,e2) -> (match op with
		|Lt | Gt | Leq | Geq -> Bool
		|_-> let t1 = analyseExpression e1 environnement in
				 let t2 = analyseExpression e2 environnement in
				 match (t1,t2) with
				 |(Int,Int) -> Int
				 |_->failwith "Opération arithmétiques mal typés"
	)
;;

let rec analyseInstr instr environnement=
	match instr with
	| Expr e -> analyseExpression e environnement
	|Putchar e -> analyseExpression e environnement
	|Set(s,e) -> (* A faire, vérifier que s et e sont de même type*) analyseExpression e environnement
	|If(condition,e1,e2) -> (match ( analyseExpression condition environnement ,e1,e2) with
		|(Bool,e1,e2) -> analyseInstr (List.nth e1 0) environnement
		|_->failwith("La condition n'est pas un booléean")
	)
	|While(condition,e) -> (match ( analyseExpression condition environnement ,e) with
		|(Bool,_)->analyseInstr (List.nth e 0) environnement
		|_->failwith "Ce n'est pas une boucle while")
	| Return e -> analyseExpression e environnement
;;

let analyseFonction fun_definition =
	(* 1. Verifie existe pas deja*)
	if Hashtbl.find_opt infoFunctions fun_definition.SyntaxeAbstr.name  != None
	then failwith "ERREUR deux fonctions de meme nom !!!" else (Hashtbl.add infoFunctions fun_definition.SyntaxeAbstr.name fun_definition);
	
	(*2. creation Hashtbl de parametre*)
	let parametres : (string,SyntaxeAbstr.typ ) Hashtbl.t   =  Hashtbl.create 4 in
	let rec hashPara l = match l with 
	 	| [] -> ()
		 | (i,t)::tl -> match Hashtbl.find_opt parametres i with
			 |None -> Hashtbl.add parametres i t;hashPara tl
			 |_->failwith "Erreur: 2 paramètres du même nom.";
		 
	in
	hashPara fun_definition.SyntaxeAbstr.params;
	(* A faire, appeler cette fonciton, un message meileur: inclure le nom du param en question*)
			 
	let locales = Hashtbl.create 4 in
	 let rec hashLocal l =
	 	match l with 
	 	| [] -> ()
		 | (i,t)::tl -> match Hashtbl.find_opt locales i with 
			 |None -> (match Hashtbl.find_opt parametres i with
				 | None -> Hashtbl.add locales i t; hashLocal tl
				 |_-> Printf.printf "La variable %s a été masquée" i;Hashtbl.remove parametres i; Hashtbl.add locales i t;hashLocal tl;)
			|_-> let message = Printf.sprintf "La variable %s a été défini 2 fois." i in failwith message
	in

	hashLocal fun_definition.SyntaxeAbstr.locals;
	(* A faire, appeler cette fonction*)
	(* Analyser les instructions*)
	()
;;


let rec analyseFonctions l =
	match l with
		| []->()
		| hd::tl -> analyseFonction(hd); analyseFonctions tl
;;

let analyseProgramme prog =
	creaGlobales prog.globals;
	analyseFonctions prog.functions
;;