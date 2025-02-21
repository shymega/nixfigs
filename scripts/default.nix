{ pkgs, ... }:
let
  inherit (pkgs) lib;
  scripts = builtins.readDir ./.;
  scriptMapFunction = script:
    let
      filename = lib.removeSuffix ".sh" script;
    in
    pkgs.writeShellScriptBin filename builtins.readFile script;
in
builtins.map scriptMapFunction scripts
