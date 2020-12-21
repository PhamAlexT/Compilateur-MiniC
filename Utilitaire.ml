(*transforme un mot en un tableau de chaque caractere : toto -> ['t', 'o', 't', 'o']*)
let stringToTabChar s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []
;;

(*Valeur du mot avec le code ASCII*)
let sumASCIIofString s =
  let t1 = stringToTabChar s in
  let rec aux l acc = match l with 
    |[]->acc
    | hd::tl -> aux tl (acc+Char.code hd)
  in
  aux t1 0
;;

(*retourne le gap entre deux mots*)
let gapWord s1 s2 =
  let t1 = sumASCIIofString s1 in
  let t2 = sumASCIIofString s2 in

  let diff = abs_float ((float_of_int t1)-.(float_of_int t2)) in
  let max = float_of_int (max t1 t2) in
  diff/.max *. 100.0
;;

(*renvoie vrai si les deux mots sont proches et on on aurait pu confoncre*)
let isClose s1 s2 =
  if ((gapWord s1 s2 ) < 21.0) && ( 0. < (gapWord s1 s2 ))  then true else false
;;
