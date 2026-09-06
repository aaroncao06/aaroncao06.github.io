(* Translates validated website IR values into HTML. *)

let escape_html (raw_text : string) : string =
  let output = Buffer.create (String.length raw_text) in
  String.iter
    (function
      | '&' -> Buffer.add_string output "&amp;"
      | '<' -> Buffer.add_string output "&lt;"
      | '>' -> Buffer.add_string output "&gt;"
      | '"' -> Buffer.add_string output "&quot;"
      | '\'' -> Buffer.add_string output "&#39;"
      | character -> Buffer.add_char output character)
    raw_text;
  Buffer.contents output

let render_internal_asset_path path =
  if String.starts_with ~prefix:"/" path then path else "/" ^ path

let page_output_path (page : Ir.page) : string =
  let path = Ir.path page in
  let length = String.length path in
  let start =
    if length > 0 && path.[0] = '/' then 1 else 0
  in
  let stop =
    if length > start && path.[length - 1] = '/' then length - 1 else length
  in
  let relative_path = String.sub path start (stop - start) in
  if relative_path = "" then
    "index.html"
  else
    relative_path ^ "/index.html"

let render_link_target : Ir.link_target -> string = function
  | Internal (Page (Page_ref path)) -> path
  | Internal (Asset (Asset_ref path)) -> render_internal_asset_path path
  | External url -> url

let render_asset_target : Ir.asset_target -> string = function
  | Internal (Asset_ref path) -> render_internal_asset_path path
  | External url -> url

let render_attribute (attribute : Ir.attribute) : string =
  match attribute.value with
  | String_value value ->
    " " ^ attribute.name ^ "=\"" ^ escape_html value ^ "\""
  | Link_value target ->
    " "
    ^ attribute.name
    ^ "=\""
    ^ escape_html (render_link_target target)
    ^ "\""
  | Asset_value (_, target) ->
    " "
    ^ attribute.name
    ^ "=\""
    ^ escape_html (render_asset_target target)
    ^ "\""
  | Boolean_value -> " " ^ attribute.name

let render_element element =
  Ir.fold_element
    ~text:escape_html
    ~element:(fun ~tag ~attributes ~children ~is_void ->
      let attributes = String.concat "" (List.map render_attribute attributes) in
      let opening_tag = "<" ^ tag ^ attributes ^ ">" in
      if is_void then
        opening_tag
      else
        opening_tag ^ String.concat "" children ^ "</" ^ tag ^ ">")
    element

let render_page (page : Ir.page) : string =
  let title = escape_html (Ir.title page) in
  let body = String.concat "" (List.map render_element (Ir.body page)) in
  Printf.sprintf
    {|<!doctype html><html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>%s</title></head>
<body>%s</body></html>|}
    title
    body

let render_pages (pages: Ir.page list) : (string * string) list = (* map path to rendered string *)
  List.map 
    (fun page -> (page_output_path page, render_page page))
     pages