(* Defines the homepage as an IR value. *)

open Website_compiler.Ir

let body =
  [ heading H1 [ text "Aaron Cao" ]
  ; paragraph
      [ text
          "I am generally interested in building and understanding intelligent systems, particularly by drawing on observations about human cognition. Specifically, my current interests include multimodal models, recurrent models, pre-pretraining, and programming languages. But hard problems in general are cool."
      ]
  ; Shared.external_links
  ; thematic_break ()
  ]
  @ Projects.section
  @ Thoughts.section

let page : page =
  page
    ~path:"/"
    ~title:"Aaron Cao"
    ~body
