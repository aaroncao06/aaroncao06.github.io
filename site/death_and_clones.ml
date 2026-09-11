(* Defines the note on death, clones, and the continuity of the self. *)

open Website_compiler.Ir

let page : page =
  page
    ~path:"/thoughts/on-death-and-clones/"
    ~title:"On Death and Clones — Aaron Cao"
    ~body:
      [ heading H1 [ text "On Death and Clones" ]
      ; paragraph
          [ text
              "For this thought experiment, assume time is discrete, treat death only as ceasing to exist rather than the process of dying, and ignore death’s effects on others. Also assume an aversion to this notion of a painless and isolated death."
          ]
      ; heading H2 [ text "Self" ]
      ; paragraph
          [ text
              "The only thing I can know is this experience of being conscious. The underlying reality could be a simulation for all I know, but that would be irrelevant to the experience itself. My sense of self is constructed solely from the snapshot of memories and observations in my current instance of consciousness."
          ]
      ; paragraph
          [ text
              "On this view, “I” exist only at one timestep at a time. The conscious self from a second ago no longer exists. My current memories contain information about previous timesteps, producing the impression of one coherent self persisting through time."
          ]
      ; heading H2 [ text "Clones" ]
      ; paragraph
          [ text
              "Suppose you suddenly die painlessly. A moment later, an exact clone is constructed with the same hardware and a copy of all your memories. My first instinct is that the clone is a different entity. Undesirably, I would still be dead, and the clone would merely believe that it had continued my stream of consciousness."
          ]
      ; paragraph
          [ text
              "But is this not what happens at every timestep? My present self is a successor to an instance of consciousness that no longer exists. It is connected to that previous instance through memory and inferred causal continuity, but it is not literally the same conscious moment and thus is not the same “self.” In that sense, I am like a clone of the previous version of myself, which is now nonexistent and “dead.”"
          ]
      ; heading H2 [ text "Death" ]
      ; paragraph
          [ text
              "This produces a tension. If I consider the clone a separate being, why do I care about my hypothetical future self, which is also a successor to my current instance? If I include ordinary future instances in my sense of self, why would I exclude an exact clone that continues with the same memories?"
          ]
      ; paragraph
          [ text
              "If I knew that a clone would replace me after I died, I would still fear death because I would believe that I was about to cease to exist. But why do I not fear that at every instant? On this view, my current instance of consciousness is constantly snapping out of existence and being replaced by the next one. In both cases a successor remains, but only one feels like death."
          ]
      ; paragraph
          [ text
              "An intuition for why we do not care about clones in the same way that we care about our future selves is that we value continuity of existence. But consciousness and memory contain discontinuities all the time. We do not go to sleep in fear that the current self will disappear and a successor will wake up."
          ]
      ; paragraph
          [ text
              "We deeply believe in and are biologically inclined to care for the continuous self inferred from our memory snapshot. The biological function we optimize is necessarily based on future states, because current and past states cannot be changed. Even if I understand my future self as something like a clone, my current value function still cares about it."
          ]
      ; paragraph
          [ text
              "There is a difference between what could be metaphysically true and what we psychologically believe. Personal identity may function like continuous replacement, while we still experience future continuity as meaningful and death as fundamentally different."
          ]
      ; paragraph
          [ link (link_to_page (Page_ref "/")) [ text "Back" ] ]
      ]
