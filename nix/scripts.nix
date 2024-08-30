_final: prev:
with prev.lib;
let
  # Credit: https://www.reddit.com/r/NixOS/comments/15hedyu/install_directory_full_of_scripts_recursively/
  # This function extracts the basename of a file
  basename = path: lists.last (strings.splitString "/" (toString path));
  # Generate a flat list of files recursively
  files = filesystem.listFilesRecursive ../scripts;
  mapScriptFn = file:
    let
      base = basename file;
    in
    {
      "${base}" = prev.writeScriptBin base (builtins.readFile file);
    };
in
forEach files mapScriptFn
