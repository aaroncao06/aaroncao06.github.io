(* Defines the typed intermediate representation shared by the site and compiler. *)

type link_target =
  | Internal of string
  | External of string

type heading_level =
  | H1
  | H2
  | H3
  | H4
  | H5
  | H6

(* placement constraint: flow_only cannot go inside phrasing *)
type phrasing = unit
type flow_only = unit

(* interaction constraint: contains_interaction cannot go inside no_interaction *)
type no_interaction = unit
type contains_interaction = unit

type attribute_value =
  | String_value of string
  | Link_value of link_target
  | Boolean_value

type attribute =
  { name : string
  ; value : attribute_value
  }

type node =
  | Text_node of string
  | Element_node of
      { tag : string
      ; attributes : attribute list
      ; children : node list
      ; is_void : bool
      }

type (+'placement, +'interaction) element = node
type +'interaction list_item = node list

let make_element tag ?(attributes = []) children =
  Element_node { tag; attributes; children; is_void = false }

let make_void_element tag ?(attributes = []) () =
  Element_node { tag; attributes; children = []; is_void = true }

let text value = Text_node value

let link target children =
  make_element
    "a"
    ~attributes:[ { name = "href"; value = Link_value target } ]
    children

let emphasis children = make_element "em" children
let strong children = make_element "strong" children
let code children = make_element "code" children

let image ~source ~alt () =
  make_void_element
    "img"
    ~attributes:
      [ { name = "src"; value = Link_value source }
      ; { name = "alt"; value = String_value alt }
      ]
    ()

let line_break () = make_void_element "br" ()

let heading level children =
  let tag =
    match level with
    | H1 -> "h1"
    | H2 -> "h2"
    | H3 -> "h3"
    | H4 -> "h4"
    | H5 -> "h5"
    | H6 -> "h6"
  in
  make_element tag children

let paragraph children = make_element "p" children
let preformatted children = make_element "pre" children

let code_block contents =
  make_element "pre" [ make_element "code" [ Text_node contents ] ]

let list_item children = children

let make_list tag items =
  make_element tag (List.map (make_element "li") items)

let unordered_list items = make_list "ul" items
let ordered_list items = make_list "ol" items
let block_quote children = make_element "blockquote" children
let thematic_break () = make_void_element "hr" ()

type page =
  { path : string
  ; title : string
  ; body : node list
  }

type website = page list

let page ~path ~title ~body = { path; title; body }
let path page = page.path
let title page = page.title
let body page = page.body
let with_path page ~path = { page with path }

let map_link_targets transform page =
  let map_attribute attribute =
    match attribute.value with
    | Link_value target ->
      { attribute with value = Link_value (transform target) }
    | String_value _ | Boolean_value -> attribute
  in
  let rec map_node = function
    | Text_node _ as node -> node
    | Element_node { tag; attributes; children; is_void } ->
      Element_node
        { tag
        ; attributes = List.map map_attribute attributes
        ; children = List.map map_node children
        ; is_void
        }
  in
  { page with body = List.map map_node page.body }

let fold_element ~text ~element root =
  let rec fold = function
    | Text_node contents -> text contents
    | Element_node { tag; attributes; children; is_void } ->
      element
        ~tag
        ~attributes
        ~children:(List.map fold children)
        ~is_void
  in
  fold root
