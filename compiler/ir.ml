(* Defines the intermediate representation shared by the site and compiler. *)

type inline_element =
  | Text of string
  | Link of string * string
  | Emphasis of inline_element list
  | Strong of inline_element list

type inline = inline_element list

type heading_level =
  | H1
  | H2
  | H3
  | H4
  | H5
  | H6

type block =
  | Heading of heading_level * inline
  | Paragraph of inline
  | Preformatted of string
  | Unordered_list of inline list
  | Ordered_list of inline list
  | Code_block of string
  | Block_quote of block list
  | Thematic_break

type page =
  { path : string
  ; title : string
  ; body : block list
  }

type website = page list
