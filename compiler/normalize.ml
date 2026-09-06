(* Normalizes website paths before validation and rendering. *)

let normalize_page_path path =
  let components =
    List.filter
      (fun component -> component <> "")
      (String.split_on_char '/' path)
  in
  match components with
  | [] -> "/"
  | _ -> "/" ^ String.concat "/" components ^ "/"

let normalize_link_target : Ir.link_target -> Ir.link_target = function
  | Internal (Page (Page_ref path)) ->
    Ir.link_to_page (Page_ref (normalize_page_path path))
  | target -> target

let normalize_page (page : Ir.page) : (Ir.page, string) result =
  let normalized_page =
    Ir.with_path page ~path:(normalize_page_path (Ir.path page))
  in
  Ok (Ir.map_link_targets normalize_link_target normalized_page)

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
