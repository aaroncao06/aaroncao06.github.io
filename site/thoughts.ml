(* Defines the thoughts section included by the homepage. *)

open Website_compiler.Ir

let section =
  [ heading H2 [ text "“Interesting” thoughts" ]
  ; paragraph
      [ text
          "How often do you think of something that you are surprised to find yourself thinking?"
      ]
  ; unordered_list
      [ list_item
          [ paragraph
              [ strong
                  [ link
                      (link_to_page
                         (Page_ref "/thoughts/on-death-and-clones/"))
                      [ text "On Death and Clones" ]
                  ]
              ]
          ]
      ; list_item
          [ strong [ text "The Shaved Eyebrow Illusion:" ]
          ; paragraph
              [ text
                  "Consider the following facts. Your eyebrow hairs stay around a certain length. If you shave them, they will grow back to roughly that same length. The exposed hair is dead, so the follicle cannot tell that it was shaved or directly sense how long the hair is."
              ]
          ; paragraph
              [ text
                  "If the follicle cannot tell that the hair was shaved, why does shaving seem to restart growth? And if the hair could regrow, why was it not always continuously growing? Why do we not have infinitely long eyebrows?"
              ]
          ; paragraph
              [ text
                  "In other words, it appears as if hair grows as a function of its length, but that cannot be true. What might really be going on?"
              ]
          ; paragraph
              [ link
                  (link_to_page
                     (Page_ref "/thoughts/shaved-eyebrow-illusion/"))
                  [ text
                      "Answer (mostly inferable from first principles, not random biology magic)"
                  ]
              ]
          ]
      ; list_item
          [ paragraph [ strong [ text "Weird words:" ] ]
          ; unordered_list
              [ list_item [ text "Queueing" ]
              ; list_item [ text "Weren’t" ]
              ]
          ]
      ; list_item
          [ paragraph [ strong [ text "The TriniTea:" ] ]
          ; paragraph
              [ image
                  ~width:320
                  ~source:(asset_source (Asset_ref "assets/trinitea.jpg"))
                  ~alt:"Three cans of tea next to each other"
                  ()
              ]
          ]
      ]
  ]
