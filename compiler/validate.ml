(* Validates website IR values before they are translated into outputs. *)

(*TODO: other checks for like valid internal links and etc*)

(* Checks that every page has a unique path. *)
let rec has_duplicate_paths
  (seen_paths : string list)
  (pages : Ir.page list)
  : (unit, string) result
=
match pages with
| [] -> Ok ()
| page :: remaining_pages ->
  let path = Ir.path page in
  if List.mem path seen_paths then
    Error ("Duplicate page path: " ^ path)
  else
    has_duplicate_paths (path :: seen_paths) remaining_pages

let validate (website : Ir.website) : (unit, string) result =
  has_duplicate_paths [] website
