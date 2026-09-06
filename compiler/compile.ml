(* Will orchestrate normalization, validation, rendering, and output. *)

let run (website : Ir.website): (unit, string) result =
  let (let*) = Result.bind in
  let* normalized_website = Normalize.normalize website in
  let* () = Validate.validate normalized_website in
  let rendered_pages = Html.render_pages normalized_website.pages in
  let* () = Output.write_pages ~output_root:"dist" rendered_pages in
  Output.copy_assets ~output_root:"dist" normalized_website.assets
