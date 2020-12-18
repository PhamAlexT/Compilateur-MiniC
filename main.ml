let () =
  let fichier = Sys.argv.(1) in
  let c = open_in fichier in
  let lexbuf = Lexing.from_channel c in
  let prog = AnalyseurSyntaxique.prog AnalyseurLexical.token lexbuf in
  ignore(prog);
  close_in c;
  Printf.printf "Fin \n";