open Website_compiler

let failures = ref 0

let fail message = raise (Failure message)

let expect_equal expected actual =
  if actual <> expected then
    fail (Printf.sprintf "expected %S but got %S" expected actual)

let expect_error expected = function
  | Error actual -> expect_equal expected actual
  | Ok _ -> fail (Printf.sprintf "expected Error %S but got Ok" expected)

let expect_ok = function
  | Ok () -> ()
  | Error message -> fail ("expected Ok but got Error: " ^ message)

let contains text substring =
  let text_length = String.length text in
  let substring_length = String.length substring in
  let rec loop offset =
    if offset + substring_length > text_length then
      false
    else if String.sub text offset substring_length = substring then
      true
    else
      loop (offset + 1)
  in
  substring_length = 0 || loop 0

let expect_contains substring text =
  if not (contains text substring) then
    fail (Printf.sprintf "expected %S to contain %S" text substring)

let test name run =
  try
    run ();
    Printf.printf "ok: %s\n" name
  with
  | exception_ ->
    incr failures;
    Printf.eprintf "FAILED: %s\n  %s\n" name (Printexc.to_string exception_)

let empty_page path = Ir.page ~path ~title:"Test" ~body:[]

let normalize website =
  match Normalize.normalize website with
  | Ok normalized -> normalized
  | Error message -> fail message

let test_page_path_normalization () =
  expect_equal "/" (Normalize.normalize_page_path "");
  expect_equal "/" (Normalize.normalize_page_path "///");
  expect_equal "/guide/" (Normalize.normalize_page_path "guide");
  expect_equal "/guide/" (Normalize.normalize_page_path "/guide/");
  expect_equal "/guides/start/" (Normalize.normalize_page_path "//guides//start")

let test_internal_page_link_normalization () =
  let page =
    Ir.page
      ~path:"guide"
      ~title:"Guide"
      ~body:
        [ Ir.paragraph
            [ Ir.link
                (Ir.link_to_page (Ir.Page_ref "about"))
                [ Ir.text "About" ]
            ]
        ]
  in
  let website = normalize { Ir.pages = [ page ]; assets = [] } in
  let page = List.hd website.pages in
  expect_equal "/guide/" (Ir.path page);
  expect_contains "href=\"/about/\"" (Html.render_page page)

let test_normalized_duplicate_page_paths () =
  let website =
    normalize
      { Ir.pages = [ empty_page "/guide"; empty_page "/guide/" ]
      ; assets = []
      }
  in
  expect_error "Duplicate page path: /guide/" (Validate.validate website)

let test_missing_internal_page () =
  let page =
    Ir.page
      ~path:"/"
      ~title:"Home"
      ~body:
        [ Ir.paragraph
            [ Ir.link
                (Ir.link_to_page (Ir.Page_ref "/missing/"))
                [ Ir.text "Missing" ]
            ]
        ]
  in
  let website = normalize { Ir.pages = [ page ]; assets = [] } in
  expect_error "Nonexistent page path: /missing/" (Validate.validate website)

let test_missing_internal_asset () =
  let page =
    Ir.page
      ~path:"/"
      ~title:"Home"
      ~body:
        [ Ir.image
            ~source:(Ir.asset_source (Ir.Asset_ref "assets/missing.png"))
            ~alt:"Missing"
            ()
        ]
  in
  let website = normalize { Ir.pages = [ page ]; assets = [] } in
  expect_error
    "Nonexistent asset path: assets/missing.png"
    (Validate.validate website)

let test_incorrect_asset_kind () =
  let path = "assets/not-an-image.txt" in
  let page =
    Ir.page
      ~path:"/"
      ~title:"Home"
      ~body:
        [ Ir.image
            ~source:(Ir.asset_source (Ir.Asset_ref path))
            ~alt:"Wrong kind"
            ()
        ]
  in
  let asset =
    Ir.asset ~source_path:"source.txt" ~output_path:path ~kind:Ir.File
  in
  let website = normalize { Ir.pages = [ page ]; assets = [ asset ] } in
  expect_error ("Incorrect asset kind: " ^ path) (Validate.validate website)

let test_html_escaping () =
  let page =
    Ir.page
      ~path:"/"
      ~title:"A&B <site>"
      ~body:[ Ir.paragraph [ Ir.text "<hello> & \"goodbye\"" ] ]
  in
  let html = Html.render_page page in
  expect_contains "<title>A&amp;B &lt;site&gt;</title>" html;
  expect_contains "<p>&lt;hello&gt; &amp; &quot;goodbye&quot;</p>" html

let test_lowering () =
  let page = empty_page "/guide/" in
  let asset =
    Ir.asset
      ~source_path:"source/photo.png"
      ~output_path:"assets/photo.png"
      ~kind:Ir.Image
  in
  match Compile.lower { Ir.pages = [ page ]; assets = [ asset ] } with
  | [ Output.Generated { path = "guide/index.html"; _ }
    ; Output.Copied
        { path = "assets/photo.png"; source_path = "source/photo.png" }
    ] ->
    ()
  | _ -> fail "website did not lower to the expected output plan"

let generated path = Output.Generated { path; contents = "" }

let test_duplicate_output_paths () =
  expect_error
    "Conflicting output paths: index.html and index.html"
    (Output.validate [ generated "index.html"; generated "index.html" ])

let test_ancestor_output_paths () =
  expect_error
    "Conflicting output paths: guide and guide/index.html"
    (Output.validate [ generated "guide"; generated "guide/index.html" ])

let with_temporary_directory run =
  let path = Filename.temp_file "website-compiler-test-" "" in
  Sys.remove path;
  Unix.mkdir path 0o700;
  Fun.protect ~finally:(fun () -> Unix.rmdir path) (fun () -> run path)

let test_writer_rejects_unsafe_path_before_writing () =
  with_temporary_directory (fun temporary_directory ->
    let output_root = Filename.concat temporary_directory "output" in
    expect_error
      "Unsafe output path: ../escaped"
      (Output.write
         ~output_root
         [ Output.Generated { path = "../escaped"; contents = "bad" } ]);
    if Sys.file_exists output_root then
      fail "writer created the output directory before rejecting the plan")

let test_missing_asset_source_raises_error () =
  with_temporary_directory (fun temporary_directory ->
    let output_root = Filename.concat temporary_directory "output" in
    let missing_source = Filename.concat temporary_directory "missing.png" in
    let result =
      Output.write
        ~output_root
        [ Output.Copied
            { path = "assets/missing.png"; source_path = missing_source }
        ]
    in
    (match result with
     | Error message ->
       expect_contains ("Could not copy " ^ missing_source) message
     | Ok () -> fail "expected copying a missing asset to fail");
    if Sys.file_exists output_root then
      fail "failed build replaced the output directory")

let test_failed_build_preserves_previous_output () =
  with_temporary_directory (fun temporary_directory ->
    let output_root = Filename.concat temporary_directory "output" in
    let index_path = Filename.concat output_root "index.html" in
    expect_ok
      (Output.write
         ~output_root
         [ Output.Generated { path = "index.html"; contents = "old" } ]);
    let missing_source = Filename.concat temporary_directory "missing.png" in
    let result =
      Output.write
        ~output_root
        [ Output.Generated { path = "index.html"; contents = "new" }
        ; Output.Copied
            { path = "assets/missing.png"; source_path = missing_source }
        ]
    in
    (match result with
     | Error _ -> ()
     | Ok () -> fail "expected the replacement build to fail");
    let contents = In_channel.with_open_bin index_path In_channel.input_all in
    expect_equal "old" contents;
    Sys.remove index_path;
    Unix.rmdir output_root)

let test_successful_build_removes_stale_outputs () =
  with_temporary_directory (fun temporary_directory ->
    let output_root = Filename.concat temporary_directory "output" in
    let stale_path = Filename.concat output_root "stale.html" in
    let current_path = Filename.concat output_root "index.html" in
    expect_ok
      (Output.write
         ~output_root
         [ Output.Generated { path = "stale.html"; contents = "stale" } ]);
    expect_ok
      (Output.write
         ~output_root
         [ Output.Generated { path = "index.html"; contents = "current" } ]);
    if Sys.file_exists stale_path then
      fail "successful build retained a stale output";
    let contents = In_channel.with_open_bin current_path In_channel.input_all in
    expect_equal "current" contents;
    Sys.remove current_path;
    Unix.rmdir output_root)

let () =
  test "page path normalization" test_page_path_normalization;
  test "internal page link normalization" test_internal_page_link_normalization;
  test "normalized duplicate page paths" test_normalized_duplicate_page_paths;
  test "missing internal page" test_missing_internal_page;
  test "missing internal asset" test_missing_internal_asset;
  test "incorrect asset kind" test_incorrect_asset_kind;
  test "HTML escaping" test_html_escaping;
  test "output lowering" test_lowering;
  test "duplicate output paths" test_duplicate_output_paths;
  test "ancestor output paths" test_ancestor_output_paths;
  test
    "writer rejects unsafe paths before writing"
    test_writer_rejects_unsafe_path_before_writing;
  test "missing asset source raises an error" test_missing_asset_source_raises_error;
  test
    "failed build preserves previous output"
    test_failed_build_preserves_previous_output;
  test
    "successful build removes stale outputs"
    test_successful_build_removes_stale_outputs;
  if !failures > 0 then
    exit 1
