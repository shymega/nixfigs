{ config, pkgs, lib, ... }:

let
  impermanence = builtins.fetchTarball
    "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in {
  imports = [ "${impermanence}/nixos.nix" ];

  # this folder is where the files will be stored (don't put it in tmpfs)
  environment.persistence."/etc/nixos/persist/system" = {
    directories = [ "/etc/NetworkManager" ];
  };

  services.resolved = {
    enable = true;
    fallbackDns = [ "8.8.8.8" "2001:4860:4860::8844" ];
  };
}
