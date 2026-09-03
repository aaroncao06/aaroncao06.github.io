(* Defines the homepage as an IR value. *)

open Website_compiler.Ir

let page : page =
  page
    ~path:"/"
    ~title:"Aaron Cao"
    ~body:
      [ heading H1 [ text "Aaron Cao" ]
      ; paragraph [ text "Hello world" ]
      ]
