(* Normalizes website paths before validation and rendering. *)

let normalize (website : Ir.website) : (Ir.website, string) result =
  let normalize_page (page : Ir.page) : (Ir.page, string) result = Ok page in
  let rec loop
      (cleaned_pages : Ir.page list)
      (unprocessed_pages : Ir.page list)
      : (Ir.website, string) result
    =
    match unprocessed_pages with
    | [] -> Ok (List.rev cleaned_pages)
    | page :: remaining_pages ->
      match normalize_page page with
      | Ok normalized_page ->
        loop (normalized_page :: cleaned_pages) remaining_pages
      | Error message -> Error message
  in
  loop [] website
