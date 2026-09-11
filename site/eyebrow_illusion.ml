(* Defines the answer to the shaved eyebrow illusion. *)

open Website_compiler.Ir

let page : page =
  page
    ~path:"/thoughts/shaved-eyebrow-illusion/"
    ~title:"The Shaved Eyebrow Illusion — Aaron Cao"
    ~body:
      [ heading H1 [ text "The Shaved Eyebrow Illusion" ]
      ; paragraph
          [ text
              "Hair follicles grow hair as a function of time with independent life cycles. They grow a hair, stop, shed it, then start again. The hair that you observe \"regrowing\" to full length is not the same hair that was shaved. The shaved hairs generally stop growing and shed before reaching full length again. Head hair grows longer because its growth phase lasts longer."
          ]
      ; paragraph
          [ link (link_to_page (Page_ref "/")) [ text "Back" ] ]
      ]
