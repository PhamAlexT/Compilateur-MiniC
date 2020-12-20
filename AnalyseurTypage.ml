open SyntaxeAbstr
(*Hashtbl globales utilisees dans tout le programme*)
(*Hashtbl pour var globales*)
(*Hashtbl pour fonctions*)
let infoFunctions : (string,SyntaxeAbstr.fun_def) Hashtbl.t = Hashtbl.create 4;;
let varGlobales : (string,typ) Hashtbl.t = Hashtbl.create 4;

type membre_envir=
  | FunDef of fun_def
  | TypeVariable of typ

let typeToString t = 
  match t with
  | Int -> "Int"
  | Bool -> "Bool"
;;

let hashMapToList = fun h -> Hashtbl.fold (fun k v acc -> (k, v) :: acc) h [] ;;
(*fonction initialisant Hashtbl des variables globales*)
let creaGlobales  l =
  let rec aux l = 
    match l with
    | [] -> ()
    | (i , t )::tl ->
      match (Hashtbl.find_opt varGlobales i) with 
      |None-> Hashtbl.add varGlobales i t;aux tl
      |_ -> failwith ("Erreur: 2 variables globales de même nom.");
        ;
  in

  aux l;
  Printf.printf "Nombre de variable globales: %d \n" (Hashtbl.length varGlobales)
;;

(*Fonction verifiant les types des expr dans l'environnement (qui est une Hashtbl) *)
let rec analyseExpression expr (environnement: (string, membre_envir) Hashtbl.t ) : typ =
  match expr with
  (*cst : int*)
  |Cst n -> Int
  (*verifier que la variable existe ds la Hashtbl*)   
  |Get i -> (match Hashtbl.find_opt environnement i with
      |None -> let message = Printf.sprintf "Identifiant %s non défini" i in failwith message
      |Some(membre) -> match membre with
        |FunDef(_) -> let message = Printf.sprintf "Identifiant %s est une fonction mais appelé comme une variable." i in failwith message
        |TypeVariable(t) -> t)
  (*verif pour call : nb param + type retour*)
  |Call (nom,l) -> (match Hashtbl.find_opt environnement nom with
      |None -> let message = Printf.sprintf "Identifiant non défini %s" nom in failwith message
      |Some(membre) -> match membre with
        |TypeVariable(_) -> let message = Printf.sprintf "La fonction est appelé comme une variable" in failwith message
        |FunDef(fun_def) -> fun_def.SyntaxeAbstr.return) 
        (* To do : Le return de même type? Nombre d'arguments?*)
        (*ds une operation: les comparaisons obligent des bool et pour les op arithmetiques: int*) 
  |Binop(op,e1,e2) -> (match op with
      |Lt | Gt | Leq | Geq ->( match (analyseExpression e1 environnement, analyseExpression e2 environnement) with
          |(Int,Int) -> Bool
          |_-> failwith "Erreur: Les opérateurs de comparaison n'opèrent pas sur des int seulement."
        )

      |_ -> let t1 = analyseExpression e1 environnement in
        let t2 = analyseExpression e2 environnement in
        match (t1,t2) with
        |(Int,Int) -> Int
        |_->failwith "Opération arithmétiques mal typés"
    )
;;

(*Fonction analysant les instructions*)
let rec analyseInstrs instrs (environnement: (string, membre_envir) Hashtbl.t ) : typ=
  match instrs with 
  | [] -> Void
  | instr :: suites -> match instr with
    (*expr simple: on lance l'analyse sur les expr*)
    | Expr e -> analyseExpression e environnement
    (*verifie que e est bien typee + type quelconque *)
    |Putchar e -> Void
    (*verifier que s existe et que s et e soit de meme type*)
    |Set(s,e) ->( 
        let typeE = analyseExpression e environnement in Printf.printf "--Ici: expr de type %s" (typeToString typeE);
        let typeS = match Hashtbl.find environnement s with
          |FunDef(_)-> let message = Printf.sprintf "Erreur: On affecte une valeur à une fonction" in failwith message
          |TypeVariable(t)->t
        in
        Printf.printf "--Ici: s de type %s" (typeToString typeS);
        if typeE != typeS 
        then let message = Printf.sprintf "Erreur: Affectation de type non identique." in failwith message 
        else typeS
      )
    (*pour if: il suffit de verifier seulement que la condition est un bool*)
    |If(condition,s1,s2) -> (match (analyseExpression condition environnement),s1,s2 with
        |(Bool,s1,s2) -> let _ = analyseInstrs s1 environnement in 
          let _ = analyseInstrs s2 environnement in
          Void
        |_->failwith("La condition n'est pas un booléean")
      )
    (*pour while : condition doit aussi etre un bool*)
    |While(condition,s) -> (match ( analyseExpression condition environnement ,s) with
        |(Bool,s)-> analyseInstrs s environnement
        |_->failwith "Ce n'est pas une boucle while")
    (*Return : e doit etre bien type et de meme type que le type de retour de la fonction*)
    | Return e -> analyseExpression e environnement
;;

let addHashtbl htb1 htb2=
  let rec aux l2 = 
    match l2 with
    |[]-> ()
    |(i,t)::tl -> match Hashtbl.find_opt htb1 i with
      |None-> Hashtbl.add htb1 i t;aux tl
      |_-> Printf.printf "Masquage: %s" i; Hashtbl.add htb1 i t;aux tl
  in
  aux (hashMapToList htb2)
;;
(*Fonctions analysant les fonctions :*)

let analyseFonction fun_definition infosFunction =
  (* 1. Verifie existe pas deja*)
  if Hashtbl.find_opt infosFunction fun_definition.SyntaxeAbstr.name  != None
  then failwith "ERREUR deux fonctions de meme nom !!!" 
  else (Hashtbl.add infosFunction fun_definition.SyntaxeAbstr.name fun_definition);

  let environnement : (string, membre_envir) Hashtbl.t = Hashtbl.create 4 in
  let putGlobalInEnv =
    let rec aux l =
      match l with
      |[]->()
      |(nom,typeV)::tl -> Printf.printf "Type %s : %s \n" nom (typeToString typeV);Hashtbl.add environnement nom (TypeVariable typeV);aux tl
    in
    aux (hashMapToList varGlobales)
  in
  putGlobalInEnv;

  (*2. creation Hashtbl de parametre de la fonction*)
  let parametres : (string,membre_envir) Hashtbl.t   =  Hashtbl.create 4 in
  let rec hashPara l = match l with 
    | [] -> ()
    | (i,t)::tl -> match Hashtbl.find_opt parametres i with
      |None -> Printf.printf "Test: %s de type %s \n:" i (typeToString t) ; Hashtbl.add parametres i (TypeVariable t); hashPara tl
      |_-> let message = Printf.sprintf "Le parametre %s a été défini 2 fois." i in failwith message

  in
  hashPara fun_definition.SyntaxeAbstr.params;
  addHashtbl environnement parametres;

  (*3. cas des variables locales a la fonction *)
  let locales = Hashtbl.create 4 in
  let rec hashLocal l =
    match l with 
    | [] -> ()
    | (i,t)::tl -> match Hashtbl.find_opt locales i with 
      |None -> Hashtbl.add locales i (TypeVariable t); hashLocal tl
      |_-> let message = Printf.sprintf "La variable locale %s a été défini 2 fois." i in failwith message
  in
  hashLocal fun_definition.SyntaxeAbstr.locals;
  addHashtbl environnement locales;

  (* Inclure les fonctions déjà défini dans l'environnement *)
  let hashFD =
    let rec auxiliaire l = match l with
      |[]->()
      |(n,infos)::tl -> Hashtbl.add environnement n (FunDef infos); auxiliaire tl
    in
    auxiliaire (hashMapToList infosFunction)
  in
  hashFD;

  (*La fonction se connait elle même pour la récursivité*)
  Hashtbl.add environnement (fun_definition.SyntaxeAbstr.name) (FunDef fun_definition) ;

  (* On teste le typage sur toutes les instructions *)
  let _ = analyseInstrs fun_definition.SyntaxeAbstr.code environnement in

  (* TODO : Vérifier que TOUT  les return sont du même type que la fonction *)
  ()
;;


(*Verifie qu'il y a un main*)
let rec presenceMain l = 
  match l with
  | [] -> failwith("Erreur: Aucune fonction main.")
  | hd::tl -> if (hd.SyntaxeAbstr.name = "main") then () else presenceMain tl
;;

(*Fonction analyse fun_def "principal"*)

let analysesFonction l=
  let fonctionDef = Hashtbl.create 4 in (* Fonction déjà vu pour la fonction courante*)
  let rec aux l = 
    match l with 
    |[] -> Printf.printf "Les fonctions sont bien définis.\n"
    |hd::tl-> Printf.printf "Fonction analysée: %s  \n" hd.SyntaxeAbstr.name ; analyseFonction hd fonctionDef;aux tl
  in
  aux l;
;;

(*Fonction principal du verificateur de type: celle qu'on appelle ds le main*)
let analyseProgramme prog =
  presenceMain (List.rev prog.functions);
  creaGlobales (List.rev prog.globals);

  analysesFonction (List.rev prog.functions);
  Printf.printf "L'analyse de typage est terminée.\n"

;;
