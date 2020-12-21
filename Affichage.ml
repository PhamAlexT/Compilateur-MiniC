open SyntaxeAbstr
open Printf

(*aide affichage*)
let typeToString t = 
  match t with
  | Int -> "INT"
  | Bool -> "BOOL"
  | Void -> "VOID"
;;



let affichageArbre prog =
	(*cas variables globales*)
	let rec afficheGlo gg =
		match gg with 
		 | [] -> printf "\n"
	         | (nom,t)::tl -> printf "%s %s \n" (typeToString t) nom; afficheGlo tl         
	in
	afficheGlo prog.globals; 
	
	(*cas fun_def*)
	let rec afficheUneFun ff = 
		printf "%s %s ( " (typeToString ff.return) ff.name; 
		
		let rec affichePara para = 
		   match para with 
			| [] -> printf ") {\n"
	         	| (nom,t)::tl -> printf "%s %s " (typeToString t) nom; affichePara tl 
		in
		affichePara ff.params;
		
		let rec afficheLocal para = 
		   match para with 
			| [] -> printf "\n"
	         	| (nom,t)::tl -> printf "\t %s %s \n" (typeToString t) nom; afficheLocal tl 
		in
		afficheLocal ff.locals;
		
		
		printf "}"	;
	in
	
	let rec afficheFun listFun = 
		match listFun with 
		| [] -> printf "\n"
	        | hd::tl -> afficheUneFun hd; printf "\n\n"; afficheFun tl
	in
	afficheFun prog.functions;
;;
