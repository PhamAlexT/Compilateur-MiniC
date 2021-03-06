open SyntaxeAbstr
open Printf
(*Hashtbl pour var globales*)
let varGlobales : (string,typ) Hashtbl.t = Hashtbl.create 4;;

(*notre environnement est compose des variables connus a un certain moment et des fonctions deja traites : *)
(*on donne un type specifique au element en fonction de ce qu'ils sont*)

type membre_envir=
  | FunDef of fun_def
  | TypeVariable of typ
  (*aide affichage - debuggage*)
let typeToString t = 
  match t with
  | Int -> "Int"
  | Bool -> "Bool"
  | Void -> "Void"
;;

(*transforme une Hashtbl en liste*)
let hashMapToList = fun hshtbl -> Hashtbl.fold (fun k v acc -> (k, v) :: acc) hshtbl [] ;;

(* si probleme d'identifiant on regarde si il n'y a pas d'identifiant proche*)
(* appelle fonction presente ds Utilitaire*)
let messageProposition nom environnement = 
  let rec aux l = match l with
    | [] -> let msg = sprintf "Identifiant %s non défini" nom in msg
    | hd::tl -> (match Utilitaire.isClose nom (fst hd) with
        |true-> let msg = sprintf "Identifiant %s non défini, voulez-vous dire %s" nom (fst hd) in msg
        |false -> aux tl)
  in
  aux (hashMapToList environnement);
;;



(*Fonction verifiant les types des expr dans l'environnement (qui est une Hashtbl) *)
let rec analyseExpression expr (environnement: (string, membre_envir) Hashtbl.t ) : typ =
  match expr with
  (*cst : int*)
  |Cst n -> Int
  |CreaBool b -> Bool
  (*verifier que la variable existe ds la Hashtbl*)   
  |Get i -> (match Hashtbl.find_opt environnement i with
      |None -> let message = messageProposition i environnement in failwith message
      |Some(membre) -> match membre with
        |FunDef(_) -> let message = sprintf "Identifiant %s est une fonction mais appelé comme une variable." i in failwith message
        |TypeVariable(t) -> (*printf "La variable %s  est de type %s \n" i (typeToString t); *) t)
  (*verif pour call : nb param + type retour*)
  |Call (nom,l) -> (match Hashtbl.find_opt environnement nom with
      |None -> let message = sprintf "Identifiant non défini %s" nom in failwith message
      |Some(membre) -> match membre with
        |TypeVariable(_) -> let message = sprintf "La fonction est appelé comme une variable" in failwith message
        |FunDef(fun_def) -> 
          let s1 = l in (*Liste des expressions d'appels: Paramètres concrets*)
          let s2 = List.map (fun x -> snd x) fun_def.params in (* Types à respecter *)
          match ((List.length s1) = (List.length s2)) with
          |false -> let msg = (sprintf "Erreur: L'appel à la fonction %s n'a pas le bon nombre d'argument" nom) in failwith msg
          |_-> 
            let rec verification l1 l2 = 
              match (l1,l2) with
              |([],[]) -> fun_def.SyntaxeAbstr.return
              |(h1::t1,h2::t2) -> (match (analyseExpression h1 environnement) = h2 with
                  |false -> let msg = (sprintf "Un paramètre est mal typé pour l'appel à la fonction %s " nom ) in failwith msg
                  |_-> verification t1 t2)
              |_-> fun_def.SyntaxeAbstr.return
            in
            verification s1 s2)
  (*ds une operation: les comparaisons obligent des bool et pour les op arithmetiques: int*) 
  |Binop(op,e1,e2) -> (match op with
      |Lt | Gt | Leq | Geq ->( match (analyseExpression e1 environnement, analyseExpression e2 environnement) with
          |(Int,Int) -> Bool
          |_-> failwith "Erreur: Les opérateurs de comparaison n'opèrent pas sur des int seulement."
        )
      | Eq | Neq -> (let t1 = analyseExpression e1 environnement in
                     let t2 = analyseExpression e2 environnement in
                     match (t1,t2) with
                     |(Int,Int) -> Bool
                     |(Bool,Bool) -> Bool
                     |_->failwith "Opération logique mal typés")
      |_ -> let t1 = analyseExpression e1 environnement in
        let t2 = analyseExpression e2 environnement in
        match (t1,t2) with
        |(Int,Int) -> Int
        |_->failwith "Opération arithmétiques mal typés"
    )
  (* Negation de val boolenne*)
  |Not(e) -> match (analyseExpression e environnement) with
    |Bool -> Bool
    |_-> let msg = (sprintf "Une négation a été mis devant une expression non booléenne " ) in failwith msg
;;

let rec analyseExpressionGlobale expr (environnement: (string, typ) Hashtbl.t ) : typ =
  match expr with
  (*cst : int*)
  |Cst n -> Int
  |CreaBool b -> Bool
  (*verifier que la variable existe ds la Hashtbl*)   
  |Get i -> (match Hashtbl.find_opt environnement i with
      |None -> let message = "Problème pour la définition d'une variable globale." in failwith message
      |Some(membre) -> membre
      (*ds une operation: les comparaisons obligent des bool et pour les op arithmetiques: int*) 
    )
  |Binop(op,e1,e2) -> (match op with
      |Lt | Gt | Leq | Geq ->( match (analyseExpressionGlobale e1 environnement, analyseExpressionGlobale e2 environnement) with
          |(Int,Int) -> Bool
          |_-> failwith "Erreur: Les opérateurs de comparaison n'opèrent pas sur des int seulement."
        )
      | Eq | Neq -> (let t1 = analyseExpressionGlobale e1 environnement in
                     let t2 = analyseExpressionGlobale e2 environnement in
                     match (t1,t2) with
                     |(Int,Int) -> Bool
                     |(Bool,Bool) -> Bool
                     |_->failwith "Opération logique mal typés")
      |_ -> let t1 = analyseExpressionGlobale e1 environnement in
        let t2 = analyseExpressionGlobale e2 environnement in
        match (t1,t2) with
        |(Int,Int) -> Int
        |_->failwith "Opération arithmétiques mal typés"
    )
  (* Negation de val boolenne*)
  |Not(e) ->( match (analyseExpressionGlobale e environnement) with
      |Bool -> Bool
      |_-> let msg = (sprintf "Une négation a été mis devant une expression non booléenne " ) in failwith msg)
  |Call(_,_) -> failwith "Erreur, tentative d'utilisation de fonction lors de la définition de globale"


;;
(*fonction initialisant Hashtbl des variables globales*)
let creaGlobales  l =
  let rec aux l = 
    match l with
    | [] -> ()
    | (i , t , e)::tl ->
      match (Hashtbl.find_opt varGlobales i) with 
      |None-> (let t2 = analyseExpressionGlobale e varGlobales in
               match t2=t with
               |true -> Hashtbl.add varGlobales i t; aux tl
               |_->let msg = sprintf ("Erreur: La variable globale %s n'est pas bien initialisée")  i in 
                 failwith msg) 
      |_ -> failwith ("Erreur: 2 variables globales de même nom.");
        ;
  in

  aux l;
  printf "Nombre de variable globales dans le programme : %d \n\n" (Hashtbl.length varGlobales)
;;

(*Fonction analysant les instructions*)
let rec analyseInstrs instrs (environnement: (string, membre_envir) Hashtbl.t ) : typ=
  match instrs with 
  | [] -> Void
  | instr :: suites -> match instr with
    (*expr simple: on lance l'analyse sur les expr*)
    | Expr e -> analyseExpression e environnement
    (*verifie que e est bien typee + type quelconque *)
    |Putchar e -> let _ = analyseExpression e environnement in Void
    (*verifier que s existe et que s et e soit de meme type*)
    |Set(s,e) ->
      let typeE = analyseExpression e environnement in (*printf "--Ici: expr de type %s" (typeToString typeE)*)
      let typeS = match Hashtbl.find_opt environnement s with
        |None->let message =  sprintf "Erreur: L'identifiant %s n'existe pas pour l'affectation." s; in failwith message;
        |Some(FunDef(_))-> let message = sprintf "Erreur: On affecte une valeur à une fonction" in failwith message
        |Some(TypeVariable(t))->t
      in
      if typeE != typeS 
      then let message = sprintf "Erreur: Affectation de type non identique." in failwith message 
      else typeS
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

(*ajouter une Hashtbl dans une autre Hashtbl*)
let addHashtbl htb1 htb2=
  let rec aux l2 = 
    match l2 with
    |[]-> ()
    |(i,t)::tl -> match Hashtbl.find_opt htb1 i with
      |None-> Hashtbl.add htb1 i t;aux tl
      |_-> printf "Masquage: %s\n" i; Hashtbl.add htb1 i t;aux tl
  in
  aux (hashMapToList htb2)
;;

(*Fonctions analysant les fonctions :*)
let analyseFonction fun_definition infosFunction =
  (*Verifie existe pas deja*)
  if Hashtbl.find_opt infosFunction fun_definition.SyntaxeAbstr.name  != None
  then failwith "ERREUR deux fonctions de meme nom !!!" 
  else (Hashtbl.add infosFunction fun_definition.SyntaxeAbstr.name fun_definition);

  (*Cree environment et ajout var globales*)
  (*printf "Variables globales : "; *)
  let environnement : (string, membre_envir) Hashtbl.t = Hashtbl.create 4 in
  let putGlobalInEnv =
    let rec aux l =
      match l with
      |[]-> (*printf "\n"*) ()
      |(nom,typeV)::tl -> (*printf " %s : %s ; " nom (typeToString typeV);*) Hashtbl.add environnement nom (TypeVariable typeV);aux tl
    in
    aux (hashMapToList varGlobales)
  in
  putGlobalInEnv;

  (*Creation Hashtbl de parametre de la fonction*)
  let parametres : (string,membre_envir) Hashtbl.t   =  Hashtbl.create 4 in
  let rec hashPara l = match l with 
    | [] -> ()
    | (i,t)::tl -> match Hashtbl.find_opt parametres i with
      |None -> Hashtbl.add parametres i (TypeVariable t); hashPara tl
      |_-> let message = sprintf "Le parametre %s a été défini 2 fois." i in failwith message

  in
  (*printf "\t Size env: %d \n" (Hashtbl.length environnement);
    printf "\t Size params: %d\n" (List.length fun_definition.SyntaxeAbstr.params);*)
  hashPara fun_definition.SyntaxeAbstr.params;
  (*ajout ds l'environnement*)
  addHashtbl environnement parametres;

  (*printf "Size env: %d\n" (Hashtbl.length environnement);*)
  (*Cas des variables locales a la fonction *)
  let locales = Hashtbl.create 4 in
  let rec hashLocal l =
    match l with 
    | [] -> ()
    | (i,t,e)::tl -> match Hashtbl.find_opt locales i with 
      |None -> (let t2 =  analyseExpression e environnement in
                if t2 = t then (Hashtbl.add environnement i (TypeVariable t); (hashLocal tl))
                else let msg = sprintf "La variable %s est mal initialisé" i in failwith msg
               )
      |_->failwith "Variable défini 2 fois."
  in

  hashLocal fun_definition.SyntaxeAbstr.locals;
  (*ajout ds environnement*)
  addHashtbl environnement locales;
  (* printf "\t Size locals: %d\n" (List.length fun_definition.SyntaxeAbstr.locals);
     printf "\t Size env: %d \n" (Hashtbl.length environnement); *)

  (* Inclure les fonctions déjà défini dans l'environnement *)
  let hashFD =
    let rec auxiliaire l = match l with
      |[]->()
      |(n,infos)::tl -> Hashtbl.add environnement n (FunDef infos); auxiliaire tl
    in
    auxiliaire (hashMapToList infosFunction)
  in
  hashFD;


  (* printf "Nb d'instr dans la fonction %s : %d \n"  fun_definition.SyntaxeAbstr.name (List.length fun_definition.SyntaxeAbstr.code);*)

  printf "Informations environnement relatif à cette fonction :\n";
  (*printf "Size env: %d \n" (Hashtbl.length environnement);*)
  let affichage =
    let rec aux hash =
      match hash with 
      | [] -> ()
      | (nom, infos)::tl -> ( match infos with 
          | FunDef(t) -> printf "%s est une fonction de type %s \n" nom (typeToString t.SyntaxeAbstr.return);
          | TypeVariable(t) -> printf "%s est une variable de type %s \n" nom (typeToString t) ); aux tl;

    in
    aux (hashMapToList environnement) in 
  affichage;

  (* On teste le typage sur toutes les instructions *)
  let _ = analyseInstrs fun_definition.SyntaxeAbstr.code environnement in

  (*Vérifier que TOUS les return sont du même type que la fonction *)
  let analyserReturn = 
    let rec aux l =
      match l with
      |[] ->true
      |hd::tl -> match hd with
        |If(c,e1,e2) -> (aux e1) || (aux e2)
        |While(c,e) -> aux e
        |Return(e) -> if fun_definition.SyntaxeAbstr.return != (analyseExpression e environnement)
          then false else aux tl
        | _ -> aux tl
    in
    aux fun_definition.SyntaxeAbstr.code
  in

  let analyserNoReturn =
    let rec aux l = 
      match l with
      |[]->true
      |hd::tl -> (match hd with
          |Return(e)->false
          | If(c,e1,e2) -> (aux e1) || (aux e2)
          |While(c,e) -> aux e
          |_->aux tl)
    in
    aux fun_definition.SyntaxeAbstr.code
  in



  let _ = match fun_definition.SyntaxeAbstr.return with
    |Int | Bool -> (match analyserNoReturn with 
        |true-> let message = sprintf "Erreur: La fonction %s ne retourne rien alors qu'elle doit." fun_definition.SyntaxeAbstr.name in failwith message
        |false -> if analyserReturn = false then let message = sprintf "Erreur: La fonction %s n'a pas un retour de type identique à son type" fun_definition.SyntaxeAbstr.name in failwith message)
    | Void-> if analyserNoReturn = false then let message = sprintf "Erreur: La fonction %s qui est void return quelque chose." fun_definition.SyntaxeAbstr.name in failwith message
  in
  printf "\n";
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
    |[] -> printf "Les fonctions sont bien définis.\n";fonctionDef
    |hd::tl-> printf "\t Fonction analysée: %s  \n" hd.SyntaxeAbstr.name ; analyseFonction hd fonctionDef;aux tl
  in
  aux l;
;;

(*Fonction principal du verificateur de type: celle qu'on appelle ds le main*)
let analyseProgramme prog =
  presenceMain (List.rev prog.functions);
  creaGlobales (prog.globals);

  let infoFs = analysesFonction (prog.functions) in 
  printf "L'analyse de typage est terminée.\n\n";
  (varGlobales,infoFs)

;;
