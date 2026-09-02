(* Assembles the complete website from its page modules. *)

open Website_compiler.Ir

let pages : website =
  [ Home.page ]

let () =
  ignore pages
