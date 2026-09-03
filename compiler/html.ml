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

let render_link_target : Ir.link_target -> string = function
  | Internal path -> path
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
