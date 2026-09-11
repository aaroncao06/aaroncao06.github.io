(* Exposes the typed website-building API while hiding its raw tree representation. *)

type page_ref = Page_ref of string
type asset_ref = Asset_ref of string

type link_ref =
  | Page of page_ref
  | Asset of asset_ref

type +'local target = private
  | Internal of 'local
  | External of string

type link_target = link_ref target
type asset_target = asset_ref target

val link_to_page : page_ref -> link_target
val link_to_asset : asset_ref -> link_target
val asset_source : asset_ref -> asset_target
val external_target : string -> 'local target

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

(* Placement classifications. *)
type phrasing
type flow_only

(* Interaction classifications. *)
type no_interaction
type contains_interaction

type (+'placement, +'interaction) element
type +'interaction list_item

val text :
  string ->
  ('placement, 'interaction) element

val link :
  link_target ->
  ('placement, no_interaction) element list ->
  ('placement, contains_interaction) element

val emphasis :
  (phrasing, 'interaction) element list ->
  ('placement, 'interaction) element

val strong :
  (phrasing, 'interaction) element list ->
  ('placement, 'interaction) element

val code :
  (phrasing, 'interaction) element list ->
  ('placement, 'interaction) element

val image :
  ?width:int ->
  source:asset_target ->
  alt:string ->
  unit ->
  ('placement, 'interaction) element

val line_break :
  unit ->
  ('placement, 'interaction) element

val heading :
  heading_level ->
  (phrasing, 'interaction) element list ->
  (flow_only, 'interaction) element

val paragraph :
  (phrasing, 'interaction) element list ->
  (flow_only, 'interaction) element

val preformatted :
  (phrasing, 'interaction) element list ->
  (flow_only, 'interaction) element

val code_block :
  string ->
  (flow_only, 'interaction) element

val list_item :
  ('placement, 'interaction) element list ->
  'interaction list_item

val unordered_list :
  'interaction list_item list ->
  (flow_only, 'interaction) element

val ordered_list :
  'interaction list_item list ->
  (flow_only, 'interaction) element

val block_quote :
  ('placement, 'interaction) element list ->
  (flow_only, 'interaction) element

val thematic_break :
  unit ->
  (flow_only, 'interaction) element

type page
type asset
type website =
  { pages : page list
  ; assets : asset list
  }

val asset :
  source_path:string ->
  output_path:string ->
  kind:asset_kind ->
  asset

val source_path : asset -> string
val output_path : asset -> string
val kind : asset -> asset_kind

val page :
  path:string ->
  title:string ->
  body:('placement, 'interaction) element list ->
  page

val path : page -> string
val title : page -> string
val body : page -> (flow_only, contains_interaction) element list
val with_path : page -> path:string -> page
val map_link_targets : (link_target -> link_target) -> page -> page

type attribute_value =
  | String_value of string
  | Link_value of link_target
  | Asset_value of asset_kind * asset_target
  | Boolean_value

type attribute =
  { name : string
  ; value : attribute_value
  }

val fold_element :
  text:(string -> 'output) ->
  element:
    (tag:string ->
     attributes:attribute list ->
     children:'output list ->
     is_void:bool ->
     'output) ->
  ('placement, 'interaction) element ->
  'output


val iter_elements_result :
  text:(string -> (unit, 'error) result) ->
  element:
    (tag:string ->
     attributes:attribute list ->
     is_void:bool ->
     (unit, 'error) result) ->
  ('placement, 'interaction) element list ->
  (unit, 'error) result
