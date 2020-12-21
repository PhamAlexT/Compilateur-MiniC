open Printf
open SyntaxeAbstr
let hashMapToList = fun hshtbl -> Hashtbl.fold (fun k v acc -> (k, v) :: acc) hshtbl [] ;;
let nameFile = "ArbreSyntaxeAbstr.dot";;

let prepFichier file = 
  fprintf file "digraph G {
    node [shape=box];
    ratio = fill;
    nt0 [ label=\"prog\" ]; \n"
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
  |Eq -> "=="
  |Neq -> "!="
;;


let drawGlobal file global indiceLabel=
  fprintf file "nt%i [label=\" %s \"]\n nt1 -> nt%i [ label=\"\" ];\n" (indiceLabel) global (indiceLabel);;
;;

let drawGlobals file globals indiceLabel = 
  if List.length globals = 0 then ()
  else
    (fprintf file "nt0 -> nt1 [ label=\"\" ];\n"; fprintf file "nt1 [label= \" GLOBALS \"];\n");
  let rec aux l indiceLabel= match l with
    |[]->()
    | hd::tl -> drawGlobal file hd (indiceLabel+1); aux tl (indiceLabel+1)
  in
  aux globals indiceLabel;
;;

let listOfFun file l indiceLabel typeL = 
  if List.length l = 0 then 0
  else 
    let rec aux l acc = match l with
      |[]->()
      |hd :: tl -> 
        fprintf file "nt%d [label= \" %s : %s \"];\n" (indiceLabel+acc) typeL hd; aux tl (acc+1) (* Tracé du courant*);

    in
    aux l 0;
    List.length l
;;

(* Dessinne et retourne le nombre de noeuds nécessaire *)
(* TODO: Relier...?*)
let rec toNodeExp file e indiceCourant = 
  let rec aux exp indiceEcrire = match exp with
    | CreaBool(b) ->fprintf file "nt%d [label = \" BOOL \"" indiceCourant;1
    | Cst (n) -> fprintf file "nt%d [label = \" %d \"]" indiceCourant n;1
    | Get(i) -> fprintf file "nt%d [label = \" %s \"]" indiceCourant i; 1

    | Binop(op,e1,e2) -> fprintf file "nt%d [label = \" %s \"]" indiceCourant (opToString op); 
      let d1 = aux e1 (indiceCourant+1) in 
      let d2 = aux e2 (indiceCourant+d1) in (d1+d2)
    | Call(i,le) -> 
      let rec aux l acc = 
        match l with 
        |[]->acc
        |hd::tl-> let d = toNodeExp file hd acc in aux tl (d+acc) ;
      in
      aux le 0
    | Not(e) -> fprintf file "nt%d [label = \" Non \"]" indiceCourant; aux e 1
  in 
  aux e indiceCourant
;;

let rec toNodeInstr file i indiceCourant = 
  let aux s indiceCourantInterne =
    let rec aux2 s (acc : int)= 
      match s with
      |[]->acc
      |hd::tl ->let d =  (toNodeInstr file hd indiceCourantInterne ) in aux2 tl d
    in
    aux2 s 0
  in
  match i with
  | Putchar(e) -> fprintf file "nt%d [label=\" PUTCHAR \"] " indiceCourant; 
    let d = toNodeExp file e (indiceCourant+1) in  d+1;
  | Set(s,e) -> fprintf file "nt%d [label=\" Set \"] " indiceCourant;
    fprintf file "nt%d [label=\" %s \"] " (indiceCourant+1) s; let d = toNodeExp file e (indiceCourant+1) in d+2
  | If(e,s1,s2) -> fprintf file "nd%d [label=\" If \"]" indiceCourant ;
    let d0 = toNodeExp file e (indiceCourant+1) in 
    let d1 = aux s1 indiceCourant in 
    let d2 = aux s2 (indiceCourant+d1) in
    d0+d1+d2
  |While(e,s) -> fprintf file "nd%d [label=\" While \"]" indiceCourant;
    let d1 = toNodeExp file e (indiceCourant+1) in
    let d2 = aux s (d1+indiceCourant) in
    1+d1+d2
  |Return(e) -> fprintf file "nd%d [label=\" Return \"]" indiceCourant; 1 + toNodeExp file e (indiceCourant+1)
  |Expr(e) -> toNodeExp file e indiceCourant
;;
(* Retourne le nb de noeuds nécessaire pour la suite? *)
let drawFunction file f indiceLabel=
  let rec aux l acc= match l with
    |[]->acc
    |(e1,e2,e3)::tl -> let t = (e1,e2) in aux tl (t::acc)
  in 

  fprintf file  "nt%i [label= \" %s \"];\n" indiceLabel f.SyntaxeAbstr.name;
  let prov = aux f.SyntaxeAbstr.locals [] in
  let locals = List.map (fun x -> fst x) prov in
  let params = List.map (fun x -> fst x) f.SyntaxeAbstr.params in
  let nbParams = listOfFun file params (1+indiceLabel) "Params" in

  let nbLocals = listOfFun file locals (1+indiceLabel+nbParams) "Locales" in
  let idMax = nbLocals+ nbParams in 
  let rec dessinparamArgs acc = match acc with
    |0->()
    |_-> fprintf file "nt%d -> nt%d [ label = \" \" ];\n" indiceLabel (indiceLabel+acc); dessinparamArgs (acc-1)
  in
  dessinparamArgs idMax;
  idMax
;;

let drawFunctions file listF indiceLabel =
  match (List.length listF) with
  |0->Printf.printf "On est à 0 \n";()
  |_-> let _ = 
         (fprintf file "nt0 -> nt%d  [ label=\"\" ];\n" indiceLabel ;fprintf file "nt%d [label=\"FONCTIONS \"];\n" indiceLabel) in
    let rec aux file l decalage = 
      match l with
      |[]->100;
      |hd::tl -> fprintf file "nt%d ->nt%d [ label=\"\" ];\n" indiceLabel (indiceLabel+decalage);
        let offset = drawFunction file hd (indiceLabel+decalage) in 
        aux file tl (indiceLabel+decalage+offset);
    in let _ = aux file listF 1 in
    ()
;;

let getDot couplet =

  (* Récupération des noms de variables*)
  let globals = List.map (fun x -> fst x) (hashMapToList (fst couplet)) in
  (* Récupération des définitions de fonctions*)
  let defsFun = List.map (fun x->snd x) (hashMapToList (snd couplet)) in
  let file = open_out nameFile in
  (* Ecrire ...*)
  prepFichier file;

  (* Dessin des globales *)
  drawGlobals file globals 1;
  (* Dessin des fonctions *)
  drawFunctions file defsFun (2+(List.length globals));

  (* Fin,*)
  fprintf file "}";
  close_out file;

  ()
;;
let _ = getDot;;