ocamlbuild -use-menhir -menhir "menhir -v" main.native
./main.native Test/testSoft.c
dot -Tpng ArbreSyntaxeAbstr.dot -o ArbreAbstr.png
