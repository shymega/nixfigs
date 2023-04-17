{ pkgs, ... }:

let
  nix-alien-pkgs = import
    (fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master")
    { };
in {
  programs.nix-ld.enable = true;

  environment.systemPackages = with nix-alien-pkgs; [
    nix-alien
    nix-index-update
    pkgs.nix-index
  ];
}
