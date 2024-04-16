{ pkgs, ... }: rec {
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin isx86_64 isi686;
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
  isForeignNix = !isNixOS && isLinux && builtins.pathExists "/nix";
  homePrefix =
    if isDarwin then
      "/Users"
    else
      "/home";
}
