# Compilateur-MiniC - Decembre2020

# LDD3 MathsInfo - Alexandre PHAM _ Clémence SEBE

Commande pour compiler:

*ocamlbuild -use-menhir main.native*

Commande pour éxecuter:
*./main.native Exemple.c*

## Comment le compilateur fonctionne:
* Premièrement, notre compilateur vérifie qu'un main est bien présent. Dans le cas où ce n'est pas le cas, une erreur est déclenchée.
* Les globales sont toutes chargés une à une.
* Lorsqu'une fonction est analysée, nous créons un environnement qui contient:
    * Les variables globales.
    * Les paramètres.
    * Les variables locales.

* Dans les 3 cas, nous n'acceptons pas de "doublons".
    Par exemple la déclaration de 2 variables globales de même nom déclenche une erreur. 

* Cependant, si une nouvelle type de valeur a le même nom qu'une valeur précédemment déclaré, cette dernière est masquée et un avertissement est écrit par le compilateur signalant le masquage.
    Par exemple, une variable globale sera cachée si une fonction définit un paramètre de même nom.

## Ce qui a été implémenté:
* L'analyseur de type peut suggérer des noms de variables ou de fonctions si elles sont jugées pertinents. Nous en discuterons plus loin de comment il fonctionne et ce qui pouvait être fait.


## Remarques

### Suggestion
Lorsqu'un nom de variable de fonction n'est pas reconnu, on essaye de voir dans l'environnement si un nom s'y rapproche en se basant sur ce critère: 
    * Pour un mot $m_1$, nous faisons la somme du code ASCII de chaque caractère du mot que l'on nomme $s_1$.
    * De même pour un deuxième mot $m_2$ et $s_2$ et la somme défini de la même manière.
    * Posons $gap = \dfrac{| s_1 - s_2 |}{ max(s_1,s_2)} \times 100$.
    * Si $gap < 30%$, nous considérons que les mots sont suffisaments proche pour être suggéré.

Posons alors pour le nom de variable $m_1$ et $m_2$ les autres noms de variables de l'environnement. (Pour le cas ou $m_2 = m_1$ notre fonction qui juge renvoie faux)

