(* Normalizes website paths before validation and rendering. *)

let normalize_page (page : Ir.page) : (Ir.page, string) result = Ok page (*TODO: normalize path names and urls? for now i guess we can assume the user gives correct paths*)

let normalize (website : Ir.website) : (Ir.website, string) result =
  let rec loop
      (cleaned_pages : Ir.page list)
      (unprocessed_pages : Ir.page list)
      : (Ir.page list, string) result
    =
    match unprocessed_pages with
    | [] -> Ok (List.rev cleaned_pages)
    | page :: remaining_pages ->
      match normalize_page page with
      | Ok normalized_page ->
        loop (normalized_page :: cleaned_pages) remaining_pages
      | Error message -> Error message
  in
  match loop [] website.pages with
  | Ok normalized_pages -> 
    Ok {website with pages = normalized_pages}
  | Error _ as error -> error
