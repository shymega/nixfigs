{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./locale.nix
    ./fonts.nix
    ./system-services.nix
    ./packages.nix
    ./network.nix
    ./security.nix
    ./nix-alien.nix
    ./users.nix
    ./virtualisation.nix
    ./wayland.nix
    ./x11.nix
    ./custom-systemd-units.nix
  ];

  networking = {
    hostName = "NEO-LINUX";
    networkmanager = { enable = true; };
  };

  environment.shells = with pkgs; [ zsh ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
  system.autoUpgrade.enable = true;

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
  programs.zsh.enable = true;
}
