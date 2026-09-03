(* Exposes the typed website-building API while hiding its raw tree representation. *)

(* normalize internals but dont need to bother with externals *)
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
  source:link_target ->
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
type website = page list

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
