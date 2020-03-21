module S = Set.Make(String)

let imports = ref S.empty

let std_dir = Filename.dirname Sys.argv.(0)

let mod_ext = ".1ml"
let sig_ext = ".1mls"
let index_file = "index"
let modules_dir = "node_modules"

let (<|>) xO uxO =
  match xO with
  | None -> uxO ()
  | some -> some

let finish path =
  if Lib.Sys.file_exists_at path then
    Some path
  else
    None

let complete path =
  if Lib.String.is_suffix mod_ext path then
    finish path
  else if Lib.Sys.directory_exists_at path then
    finish (path ^ "/" ^ index_file ^ mod_ext)
  else
    finish (path ^ mod_ext)

let rec search_modules prefix suffix =
  complete (Filename.concat prefix modules_dir ^ "/" ^ suffix) <|> fun () ->
  let parent = Filename.dirname prefix in
  if parent = prefix then
    None
  else
    search_modules parent suffix

let resolve parent path =
  let path = Lib.Filename.canonic path in
  let path =
    if Lib.String.is_suffix sig_ext path then
      Lib.Filename.replace_ext sig_ext mod_ext path
    else
      path in
  if not (Filename.is_relative path) then
    complete path
  else if Lib.String.is_prefix "./" path || Lib.String.is_prefix "../" path then
    complete (Lib.Filename.canonic (Filename.dirname parent ^ "/" ^ path))
  else
    search_modules (Filename.dirname parent) path <|> fun () ->
    complete (std_dir ^ "/" ^ path)
