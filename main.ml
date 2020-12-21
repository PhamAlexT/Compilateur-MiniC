let () =
  Printf.printf "-------------------DEBUT PROG----------------- \n\n";
  let fichier = Sys.argv.(1) in
  let c = open_in fichier in
  let lexbuf = Lexing.from_channel c in
  (*analyse lexicale + syntaxique du programme : renvoie une liste de globals et fun_def*)
  let prog = AnalyseurSyntaxique.prog AnalyseurLexical.token lexbuf in
  (*verificateur de type sur le prog obtenu precedemment*)
  let _ = AnalyseurTypage.analyseProgramme prog in
  let _ = Affichage.affichageArbre prog in
  ignore(prog);
  close_in c;
  Printf.printf "-------------------FIN PROG----------------- \n";
