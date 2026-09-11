(* Defines the projects section included by the homepage. *)

open Website_compiler.Ir

let section =
  [ heading H2 [ text "Projects" ]
  ; strong [ text "Current" ]
  ; unordered_list
      [ list_item
          [ strong [ text "Research..." ] ]
      ; list_item
          [ strong [ text "Rgo: " ]
          ; text
              "Currently working on a Go engine and self-play training system written from scratch in Rust for maximum performance and flexible research under constrained compute budgets. Heavily inspired by "
          ; link
              (external_target "https://github.com/lightvector/KataGo")
              [ text "KataGo" ]
          ; text
              ". The AlphaGo documentary was the coolest shit ever. Coding manually is like meditation."
          ]
      ; list_item
          [ strong [ text "This website: " ]
          ; text
              "I hate frontend, so instead of vibe-coding a website, I hand-wrote an OCaml compiler and typed IR, then vibe-coded the site definitions that it compiled into this HTML. A real source language might come later. "
          ; link
              (external_target
                 "https://github.com/aaroncao06/aaroncao06.github.io")
              [ text "Code" ]
          ]
      ]
  ; strong [ text "Previous" ]
  ; unordered_list
      [ list_item
          [ strong [ text "MedSegMamba: " ]
          ; text
              "A CNN-Mamba architecture for 3D brain MRI segmentation. Training custom models from scratch is fun. "
          ; link
              (external_target "https://arxiv.org/abs/2409.08307")
              [ text "Preprint" ]
          ; text " · "
          ; link
              (external_target "https://github.com/aaroncao06/MedSegMamba")
              [ text "Code" ]
          ]
      ; list_item
          [ strong [ text "AutoRhythm: " ]
          ; text
              "When AGI takes all our jobs, what is there to do but rap? Unfortunately, nerds have no sense of rhythm, so here is a tool that snaps every syllable onto the beat while preserving the original voice (doesn’t count as AI slop this way). "
          ; link
              (external_target "https://www.youtube.com/watch?v=DkTR7YUKvEY")
              [ text "Demo" ]
          ; text " · "
          ; link
              (external_target "https://github.com/aaroncao06/AutoRhythm")
              [ text "Code" ]
          ]
      ; list_item
          [ strong [ text "Epstein Network: " ]
          ; text
              "An agentic system that turns the Epstein Files into an explorable knowledge graph. It won a datathon. "
          ; link
              (external_target "https://projectnexus-pi.vercel.app/")
              [ text "Demo" ]
          ; text " · "
          ; link
              (external_target "https://github.com/aaroncao06/projectnexus")
              [ text "Code" ]
          ]
      ]
  ]
