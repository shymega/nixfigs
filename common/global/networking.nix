{ pkgs, lib, config, ... }:

{
  networking.networkmanager.enable = true;

  networking.domain = "rodriguez.org.uk";
}
