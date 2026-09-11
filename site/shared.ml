(* Defines IR fragments shared by multiple pages. *)

open Website_compiler.Ir

let external_links =
  paragraph
    [ link (external_target "mailto:aaroncao@ucsb.edu") [ text "Email" ]
    ; text " · "
    ; link (external_target "https://github.com/aaroncao06") [ text "GitHub" ]
    ; text " · "
    ; link
        (external_target "https://www.linkedin.com/in/aaron-cao-84b180243/")
        [ text "LinkedIn" ]
    ; text " · "
    ; link
        (external_target
           "https://scholar.google.com/citations?user=dcVU2hsAAAAJ&hl=en")
        [ text "Google Scholar" ]
    ]
