open SyntaxeAbstr
(*Hashtbl globales utilisees dans tout le programme*)
(*Hashtbl pour var globales*)
let valGlobales: (string,SyntaxeAbstr.typ ) Hashtbl.t = Hashtbl.create 4;;
(*Hashtbl pour fonctions*)
let infoFunctions : (string,SyntaxeAbstr.fun_def) Hashtbl.t = Hashtbl.create 4;;



(*fonction initialisant Hashtbl des variables globales*)
let creaGlobales  l =
  let rec aux l = 
    match l with
    | [] -> ()
    | (i , t )::tl ->
      match (Hashtbl.find_opt valGlobales i) with 
      |None-> Hashtbl.add valGlobales i t;aux tl
      |_ -> failwith ("Erreur: 2 variables globales de même nom.");
			;
		in

		aux l;
    Printf.printf "Nombre de variable globales: %d \n" (Hashtbl.length valGlobales)
;;

(*Fonction verifiant les types des expr dans l'environnement (qui est une Hashtbl) *)
let rec analyseExpression expr environnement=
  match expr with
  (*cst : int*)
  |Cst n -> Int
  (*verifier que la variable existe ds la Hashtbl*)   
  |Get i -> Hashtbl.find environnement i     (*j'ai changer expr en i ???*)
  (*verif pour call : nb param + type retour*)
  |Call (nom,l) -> Int (* To do : Le return de même type? Nombre d'arguments?*)
  (*ds une operation: les comparaisons obligent des bool et pour les op arithmetiques: int*) 
  |Binop(op,e1,e2) -> (match op with
      |Lt | Gt | Leq | Geq -> Bool
      |_-> let t1 = analyseExpression e1 environnement in
        let t2 = analyseExpression e2 environnement in
        match (t1,t2) with
        |(Int,Int) -> Int
        |_->failwith "Opération arithmétiques mal typés"
    )
;;

(*Fonction analysant les instructions*)
let rec analyseInstr instr environnement=
  match instr with
  (*expr simple: on lance l'analyse sur les expr*)
  | Expr e -> analyseExpression e environnement
  (*verifie que e est bien typee + type quelconque *)
  |Putchar e -> analyseExpression e environnement
  (*verifier que s existe et que s et e soit de meme type*)
  |Set(s,e) -> (* A faire, vérifier que s et e sont de même type*) analyseExpression e environnement
  (*pour if: il suffit de verifier seulement que la condition est un bool*)
  |If(condition,e1,e2) -> (match ( analyseExpression condition environnement ,e1,e2) with
      |(Bool,e1,e2) -> analyseInstr (List.nth e1 0) environnement
      |_->failwith("La condition n'est pas un booléean")
    )
  (*pour while : condition doit aussi etre un bool*)
  |While(condition,e) -> (match ( analyseExpression condition environnement ,e) with
      |(Bool,_)->analyseInstr (List.nth e 0) environnement
      |_->failwith "Ce n'est pas une boucle while")
  (*Return : e doit etre bien type et de meme type que le type de retour de la fonction*)
  | Return e -> analyseExpression e environnement
;;

(*Fonctions analysant les fonctions :*)
let analyseFonction fun_definition =
  (* 1. Verifie existe pas deja*)
  if Hashtbl.find_opt infoFunctions fun_definition.SyntaxeAbstr.name  != None
  then failwith "ERREUR deux fonctions de meme nom !!!" else (Hashtbl.add infoFunctions fun_definition.SyntaxeAbstr.name fun_definition);

  (*2. creation Hashtbl de parametre de la fonction*)
  let parametres : (string,SyntaxeAbstr.typ ) Hashtbl.t   =  Hashtbl.create 4 in
  let rec hashPara l = match l with 
    | [] -> ()
    | (i,t)::tl -> match Hashtbl.find_opt parametres i with
      |None -> Hashtbl.add parametres i t;hashPara tl
      |_-> let message = Printf.sprintf "Le parametre %s a été défini 2 fois." i in failwith message

  in
  hashPara fun_definition.SyntaxeAbstr.params;
  
  (*3. cas des variables locales a la fonction *)
  let locales = Hashtbl.create 4 in
  let rec hashLocal l =
    match l with 
    | [] -> ()
    | (i,t)::tl -> match Hashtbl.find_opt locales i with 
      |None -> (match Hashtbl.find_opt parametres i with
          | None -> Hashtbl.add locales i t; hashLocal tl
          |_-> Printf.printf "La variable %s a été masquée\n" i;Hashtbl.remove parametres i; Hashtbl.add locales i t;hashLocal tl;)
      |_-> let message = Printf.sprintf "La variable locale %s a été défini 2 fois." i in failwith message
  in
  hashLocal fun_definition.SyntaxeAbstr.locals;

  (* Analyser les instructions*)
  (*1.creer env : fusionner Hashtbl (para + locale) + params *)
  
  (*2. fun_definition.SyntaxeAbstr.seq : list instr*)
  
  
  ()
;;


(*Verifie qu'il y a un main*)
let rec presenceMain l = 
  match l with
  | [] -> failwith("Erreur: Aucune fonction main.")
  | hd::tl -> if (hd.SyntaxeAbstr.name = "main") then () else presenceMain tl
;;

(*Fonction analyse fun_def "principal"*)
let rec analyseFonctions l =
  match l with
  | []->()
  | hd::tl -> analyseFonction(hd); analyseFonctions tl
;;


(*Fonction principal du verificateur de type: celle qu'on appelle ds le main*)
let analyseProgramme prog = 
  (*1. verifie qu'il y ait un main*)
  presenceMain prog.functions;
  (*2. creation var globales*)
  creaGlobales prog.globals;
  (*3. analyser les fonctions*)
  analyseFonctions prog.functions
;;
