(* Writes generated website files beneath an output directory. *)

type output =
  | Generated of
      { path : string
      ; contents : string
      }
  | Copied of
      { path : string
      ; source_path : string
      }

let path = function
  | Generated { path; _ } | Copied { path; _ } -> path

let safe_relative_path path =
  let components = String.split_on_char '/' path in
  path <> ""
  && Filename.is_relative path
  && List.for_all
       (fun component ->
         component <> "" && component <> "." && component <> "..")
       components

let rec is_prefix prefix values =
  match prefix, values with
  | [], _ -> true
  | _, [] -> false
  | prefix_value :: prefix_values, value :: values ->
    prefix_value = value && is_prefix prefix_values values

let paths_conflict first second =
  let first_components = String.split_on_char '/' first in
  let second_components = String.split_on_char '/' second in
  is_prefix first_components second_components
  || is_prefix second_components first_components

let validate outputs =
  let rec loop seen_paths = function
    | [] -> Ok ()
    | output :: remaining_outputs ->
      let output_path = path output in
      if not (safe_relative_path output_path) then
        Error ("Unsafe output path: " ^ output_path)
      else
        match
          List.find_opt
            (fun seen_path -> paths_conflict output_path seen_path)
            seen_paths
        with
        | Some conflicting_path ->
          Error
            ("Conflicting output paths: "
             ^ conflicting_path
             ^ " and "
             ^ output_path)
        | None -> loop (output_path :: seen_paths) remaining_outputs
  in
  loop [] outputs

let rec ensure_directory path =
  if Sys.file_exists path then
    if Sys.is_directory path then
      Ok ()
    else
      Error ("Output directory path is already a file: " ^ path)
  else
    match ensure_directory (Filename.dirname path) with
    | Error _ as error -> error
    | Ok () ->
      try
        Unix.mkdir path 0o755;
        Ok ()
      with
      | Unix.Unix_error (error, operation, _) ->
        Error
          (operation ^ " " ^ path ^ ": " ^ Unix.error_message error)

let write_file path contents =
  try
    Out_channel.with_open_bin path (fun channel ->
      Out_channel.output_string channel contents);
    Ok ()
  with
  | Sys_error message -> Error ("Could not write " ^ path ^ ": " ^ message)

let copy_file source_path output_path =
  try
    In_channel.with_open_bin source_path (fun input ->
      Out_channel.with_open_bin output_path (fun output ->
        let buffer = Bytes.create 65536 in
        let rec loop () =
          let bytes_read =
            In_channel.input input buffer 0 (Bytes.length buffer)
          in
          if bytes_read > 0 then begin
            Out_channel.output output buffer 0 bytes_read;
            loop ()
          end
        in
        loop ()));
    Ok ()
  with
  | Sys_error message ->
    Error
      ("Could not copy " ^ source_path ^ " to " ^ output_path ^ ": " ^ message)

let write ~output_root outputs =
  let ( let* ) = Result.bind in
  let* () = validate outputs in
  let* () = ensure_directory output_root in
  let rec loop = function
    | [] -> Ok ()
    | output :: remaining_outputs ->
      let relative_path = path output in
      let output_path = Filename.concat output_root relative_path in
      let* () = ensure_directory (Filename.dirname output_path) in
      let* () =
        match output with
        | Generated { contents; _ } -> write_file output_path contents
        | Copied { source_path; _ } -> copy_file source_path output_path
      in
      loop remaining_outputs
  in
  loop outputs
