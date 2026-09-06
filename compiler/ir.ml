(* Defines the typed intermediate representation shared by the site and compiler. *)

type page_ref = Page_ref of string
type asset_ref = Asset_ref of string
type link_ref =
  | Page of page_ref
  | Asset of asset_ref
type +'local target =
  | Internal of 'local
  | External of string
type link_target = link_ref target (* can link to either page or an asset *)
type asset_target = asset_ref target (* links directly to asset *)
(* 
internal of page of page ref : link navigating to internal page
internal of asset of asset ref : link navigating to/downloading internal asset
internal of page ref : unused
internal of asset ref : loading internal asset, eg images
*)

let link_to_page reference = Internal (Page reference)
let link_to_asset reference = Internal (Asset reference)
let asset_source reference = Internal reference
let external_target url = External url

type asset_kind =
  | Image
  | File

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
  | Asset_value of asset_kind * asset_target
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
      [ { name = "src"; value = Asset_value (Image, source) }
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

type asset =
  { source_path : string
  ; output_path : string
  ; kind : asset_kind}

type website =
  { pages : page list
  ; assets : asset list
  }

let asset ~source_path ~output_path ~kind = { source_path; output_path; kind }
let source_path asset = asset.source_path
let output_path asset = asset.output_path
let kind asset = asset.kind

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
    | String_value _ | Asset_value _ | Boolean_value -> attribute
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


let iter_elements_result ~text ~element elements =
  let rec process_node = function
    | Text_node contents -> text contents
    | Element_node { tag; attributes; children; is_void } ->
      match element ~tag ~attributes ~is_void with
      | Ok () -> process_nodes children
      | Error _ as error -> error
  and process_nodes = function
    | [] -> Ok ()
    | child::remaining_children ->
      match process_node child with
      | Ok () -> process_nodes remaining_children
      | Error _ as error -> error
  in
  process_nodes elements
