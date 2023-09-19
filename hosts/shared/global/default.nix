{ inputs, outputs, pkgs, ... }: {
  imports = [
    ./common_env.nix
    ./containers-cross.nix
    ./fish.nix
    ./fonts.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
  ];
}
