(* Assembles the complete website from its page modules. *)

open Website_compiler.Ir

let pages : website =
  { pages= [Home.page]
  ; assets= []}

let () =
  match Website_compiler.Compile.run pages with
  | Ok () -> ()
  | Error message -> failwith message
