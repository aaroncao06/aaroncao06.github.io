(* Assembles the complete website from its page modules. *)

open Website_compiler.Ir

let pages : website =
  { pages= [Home.page]
  ; assets= []}

let () =
  ignore pages
