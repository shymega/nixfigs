{ pkgs ? import <nixpkgs> { }
,
}:
let
  inherit (pkgs) lib;
  scripts = builtins.filter (f: f != "default.nix") (builtins.attrNames (builtins.readDir ../pkgs/scripts));
  getFilename = x: (lib.nameValuePair (lib.removeSuffix ".sh" x));
  scriptMapFunction = script: pkgs:
    let
      filename = getFilename script;
      contents = builtins.readFile ../pkgs/scripts/${filename};
    in
    {
      "${filename}" = pkgs.callPackage (pkgs.writeScriptBin "${filename}" contents);
    };
  run = builtins.map scriptMapFunction scripts;
in
run
