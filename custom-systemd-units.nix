{ config, pkgs, lib, ... }:

{
  imports = [ ./power-targets.nix ./network-targets.nix ];
}
