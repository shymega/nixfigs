{ lib, ... }: {
  imports = [ ./chown.nix ./power-targets.nix ./network-targets.nix ./power-mangement.nix ];
}
