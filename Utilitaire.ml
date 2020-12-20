let stringToTabChar s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []
;;

let sumASCIIofString s =
  let t1 = stringToTabChar s in
  let rec aux l acc = match l with 
    |[]->acc
    | hd::tl -> aux tl (acc+Char.code hd)
  in
  aux t1 0
;;

let gapWord s1 s2 =
  let t1 = sumASCIIofString s1 in
  let t2 = sumASCIIofString s2 in

  let diff = abs_float ((float_of_int t1)-.(float_of_int t2)) in
  let max = float_of_int (max t1 t2) in
  diff/.max *. 100.0
;;

let isClose s1 s2 =
  if ((gapWord s1 s2 ) < 25.0 ) then true else false
;;