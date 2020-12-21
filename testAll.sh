echo " Informations de test: Le test va planter car 2 fonctions ont le même nom"
./main.native Test/deuxFonctions.c
echo " Informations de test: Le test va planter car 2 variables globales ont le même nom"
./main.native Test/deuxGlobales.c
echo " Informations de test: Le test va planter car une fonction est appelé mais pas avec le bon nombre d'argument"
./main.native Test/mauvaisNbParamAppelFonction.c
echo " Informations de test: Le test va planter car un des paramètres d'appel d'une fonction n'est pas du bon type"
./main.native Test/mauvaisParamAppelFonction.c
echo " Informations de test: Le test va planter car un identifiant n'est pas trouvé. Une suggestion est proposée."
./main.native Test/nomproches.c
echo " Informations de test: Test simple, aucun crash"
./main.native Test/prog.c
echo " Informations de test: Test simple, aucun crash"
./main.native Test/testAff.c
echo " Informations de test: Test simple de la négation"
./main.native Test/TestNegation.c
echo " Informations de test: Test utile construit petit à petit pour l'afficheur"
./main.native Test/testSoft.c
echo " Informations de test: Le test va planter car aucun main est présent"
./main.native Test/varglobales.c
echo " Informations de test: Le test va planter car une variable n'est pas bien défini"
./main.native Test/varPasDef.c
echo " Informations de test: Le test va planter car la fonction main doit renvoyer quelquechose mais elle ne le fait pas"
./main.native Test/noreturnint.c
echo " Informations de test: Le test va planter car la fonction main ne doit pas renvoyer quelquechose mais elle le fait pas"
./main.native Test/returnvoid.c