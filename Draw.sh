ocamlbuild -use-menhir -menhir "menhir -v" main.native
./main.native Test/prog.c 
dot -Tpng ArbreSyntaxeAbstr.dot -o ArbreAbstr.png
