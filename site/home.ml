(* Defines the homepage as an IR value. *)

open Website_compiler.Ir

let page : page =
  { path = "/"
  ; title = "Aaron Cao"
  ; body =
      [ Heading (H1, [ Text "Aaron Cao" ])
      ; Paragraph [ Text "Hello world" ]
      ]
  }
