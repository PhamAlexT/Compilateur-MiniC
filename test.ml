

(**
   Typage de FUN
*)

type typ =
  | TypInt
  | TypFun of typ * typ      

type expr =
  | Cst of int
  | Add of expr * expr
  | Var of string
  | Let of string * expr * expr
  | Fun of string * typ * expr
  | App of expr * expr
      
module Env = Map.Make(String)
  
let rec type_expr (e: expr) (env: typ Env.t): typ = match e with

(*
  -------------
   Γ ⊢ n : int
*)
  | Cst _ -> TypInt

(*
   Γ ⊢ e₁ : int     Γ ⊢ e₂ : int
  -------------------------------
       Γ ⊢ Add(e₁, e₂) : int
*)
  | Add(e1, e2)
    let t1 = type_expr e1 env in
    let t2 = type_expr e2 env in
    if t1 = TypInt && t2 = TypInt
    then TypInt
    else failwith "type error"

(*
  --------------
   Γ ⊢ x : Γ(x)
*)    
  | Var(x) -> Env.find x env

(*
   Γ ⊢ e₁ : τ₁      Γ, x:τ₁ ⊢ e₂ : τ₂
  ------------------------------------
       Γ ⊢ let x = e₁ in e₂ : τ₂
*)    
  | Let(x, e1, e2) ->
    let t1 = type_expr e1 env in
    type_expr e2 (Env.add x t1 env)

(*
        Γ, x:τ₁ ⊢ e : τ₂
  ---------------------------
   Γ ⊢ fun x -> e : τ₁ ⟶ τ₂
*)
  | Fun(x, tx, e) ->
    let te = type_expr e (Env.add x tx env) in
    TypFun(tx, te)

(*
   Γ ⊢ e₁ : τ₂ ⟶ τ₁     Γ ⊢ e₂ : τ₂
  ------------------------------------
             Γ ⊢ e₁ e₂ : τ₁
*)    
  | App(f, a) ->
    let tf = type_expr f env in
    let ta = type_expr a env in
    begin match tf with
      | TypFun(tx, te) ->
        if tx = ta
        then te
        else failwith "type error"
      | _ -> failwith "type error"
    end

