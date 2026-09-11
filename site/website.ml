(* Assembles the complete website from its page modules. *)

open Website_compiler.Ir

let pages : website =
  { pages = [ Home.page; Death_and_clones.page; Eyebrow_illusion.page ]
  ; assets =
      [ asset
          ~source_path:"assets/trinitea.jpg"
          ~output_path:"assets/trinitea.jpg"
          ~kind:Image
      ]
  }

let () =
  match Website_compiler.Compile.run pages with
  | Ok () -> ()
  | Error message -> failwith message
