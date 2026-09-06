(* Validates website IR values before they are translated into outputs. *)

(* TODO: validate asset paths *)

(* Checks that every page has a unique path. *)
let rec index_pages
  (seen_pages : (string * Ir.page) list)
  (pages : Ir.page list)
  : ((string * Ir.page) list, string) result
  =
  match pages with
  | [] -> Ok seen_pages
  | page :: remaining_pages ->
    let path = Ir.path page in
    if List.mem_assoc path seen_pages then
      Error ("Duplicate page path: " ^ path)
    else
      index_pages ((path, page) :: seen_pages) remaining_pages

(* return result of list of tuples of otuput *)
let rec index_assets
  (seen_assets : (string*Ir.asset) list)
  (assets : Ir.asset list)
  : ((string*Ir.asset) list, string) result
  =
  match assets with
  | [] -> Ok seen_assets
  | asset :: remaining_assets ->
    let path = Ir.output_path asset in
    if List.mem_assoc path seen_assets then
      Error ("Duplicate asset output path: " ^ path)
    else
      index_assets ((path,asset) :: seen_assets) remaining_assets

let rec distinct_page_and_asset_outputs
  (pages_by_path : (string * Ir.page) list)
  (assets_by_path : (string * Ir.asset) list)
  : (unit, string) result
  =
  match pages_by_path with
  | [] -> Ok ()
  | (_, page) :: remaining_pages ->
    let output_path = Html.page_output_path page in
    if List.mem_assoc output_path assets_by_path then
      Error ("Page and asset output paths collide: " ^ output_path)
    else
      distinct_page_and_asset_outputs remaining_pages assets_by_path

let page_valid_internal_references (page: Ir.page) (page_by_path: (string*Ir.page) list) (assets_by_path: (string*Ir.asset) list): (unit, string) result =
  let rec valid_attributes (attributes: Ir.attribute list)  =
    match attributes with
    | [] -> Ok ()
    | attribute::remaining_attributes ->
      match attribute.value with
      (* validate whether internal path exists for links *)
      | Ir.Link_value link_target ->
        (match link_target with
        | Ir.Internal (Ir.Page (Ir.Page_ref path)) ->
          if List.mem_assoc path page_by_path then
            valid_attributes remaining_attributes
          else
            Error ("Nonexistent page path: " ^ path)
        | Ir.Internal (Ir.Asset (Ir.Asset_ref path)) ->
          if List.mem_assoc path assets_by_path then
            valid_attributes remaining_attributes
          else
            Error ("Nonexistent asset path: " ^ path)
        | _ -> valid_attributes remaining_attributes)
      (* need to check asset type for direct loading *)
      | Ir.Asset_value (expected_kind, asset_target) ->
        (match asset_target with
        | Ir.Internal (Ir.Asset_ref path) -> 
          (match List.assoc_opt path assets_by_path with
          | None -> Error ("Nonexistent asset path: " ^ path)
          | Some asset -> 
            if Ir.kind asset = expected_kind then
              valid_attributes remaining_attributes
            else
              Error ("Incorrect asset kind: " ^ path))
        | _ -> valid_attributes remaining_attributes)
      | _ -> valid_attributes remaining_attributes
  in
  Ir.iter_elements_result
    ~text:(fun _ -> Ok())
    ~element:(
      fun ~tag:_ ~attributes ~is_void:_ ->
        valid_attributes attributes
    )
    (Ir.body page)

let rec valid_internal_references (pages: Ir.page list) (page_by_path: (string*Ir.page) list) (assets_by_path: (string*Ir.asset) list) : (unit, string) result =
  match pages with
  | [] -> Ok ()
  | page::remaining_pages ->
    match page_valid_internal_references page page_by_path assets_by_path with
    | Ok () -> valid_internal_references remaining_pages page_by_path assets_by_path
    | Error _ as error -> error



let validate (website : Ir.website) : (unit, string) result =
  let (let*) = Result.bind in
  (* syntactic sugar to unwrap result and propagate *)
  let* page_by_path = index_pages [] website.pages in 
  let* assets_by_path = index_assets [] website.assets in 
  let* () = distinct_page_and_asset_outputs page_by_path assets_by_path in
  valid_internal_references website.pages page_by_path assets_by_path
  
