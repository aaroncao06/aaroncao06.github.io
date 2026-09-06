(* Will orchestrate normalization, validation, rendering, and output. *)

let lower (website : Ir.website) : Output.output list =
  let generated_pages =
    List.map
      (fun page ->
        Output.Generated
          { path = Html.page_output_path page
          ; contents = Html.render_page page
          })
      website.pages
  in
  let copied_assets =
    List.map
      (fun asset ->
        Output.Copied
          { path = Ir.output_path asset
          ; source_path = Ir.source_path asset
          })
      website.assets
  in
  generated_pages @ copied_assets

let run (website : Ir.website): (unit, string) result =
  let (let*) = Result.bind in
  let* normalized_website = Normalize.normalize website in
  let* () = Validate.validate normalized_website in
  let outputs = lower normalized_website in
  Output.write ~output_root:"dist" outputs
