(* Exposes validated output plans while hiding filesystem implementation details. *)

type output =
  | Generated of
      { path : string
      ; contents : string
      }
  | Copied of
      { path : string
      ; source_path : string
      }

val validate : output list -> (unit, string) result

val write :
  output_root:string ->
  output list ->
  (unit, string) result
