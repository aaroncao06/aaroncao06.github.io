(* Validates website IR values before they are translated into outputs. *)

(* Checks that every page has a unique path. *)
let validate (website : Ir.website) : (unit, string) result =
  let rec has_duplicate_paths
      (seen_paths : string list)
      (pages : Ir.page list)
      : (unit, string) result
    =
    match pages with
    | [] -> Ok ()
    | page :: remaining_pages ->
      let path = page.path in
      if List.mem path seen_paths then
        Error ("Duplicate page path: " ^ path)
      else
        has_duplicate_paths (path :: seen_paths) remaining_pages
  in
  has_duplicate_paths [] website
