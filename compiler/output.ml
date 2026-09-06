(* Writes generated website files beneath an output directory. *)

let safe_relative_path path =
  path <> ""
  && Filename.is_relative path
  && not (List.mem ".." (String.split_on_char '/' path))

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

let write_pages ~output_root rendered_pages =
  let ( let* ) = Result.bind in
  let* () = ensure_directory output_root in
  let rec loop = function
    | [] -> Ok ()
    | (relative_path, contents) :: remaining_pages ->
      if not (safe_relative_path relative_path) then
        Error ("Unsafe output path: " ^ relative_path)
      else
        let path = Filename.concat output_root relative_path in
        let* () = ensure_directory (Filename.dirname path) in
        let* () = write_file path contents in
        loop remaining_pages
  in
  loop rendered_pages

let copy_assets ~output_root assets =
  let ( let* ) = Result.bind in
  let* () = ensure_directory output_root in
  let rec loop = function
    | [] -> Ok ()
    | asset :: remaining_assets ->
      let relative_path = Ir.output_path asset in
      if not (safe_relative_path relative_path) then
        Error ("Unsafe asset output path: " ^ relative_path)
      else
        let output_path = Filename.concat output_root relative_path in
        let* () = ensure_directory (Filename.dirname output_path) in
        let* () = copy_file (Ir.source_path asset) output_path in
        loop remaining_assets
  in
  loop assets
