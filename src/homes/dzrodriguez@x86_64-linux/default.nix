# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  pkgs,
  inputs,
  hostPlatform,
  self,
  config,
  username,
  osConfig ? {},
  ...
} @ args: let
  isOsModule = builtins.hasAttr "config" osConfig;
in {
  imports = with inputs;
    [
      op-password-shell-plugins.hmModules.default
      shypkgs-public.hmModules.${hostPlatform}.dwl
      nix-flatpak.homeManagerModules.nix-flatpak
      shyemacs-cfg.homeModules.emacs
    ]
    ++ [
      ../configs
      ../../modules/home/nixfigs-options.nix
      ../../modules/home/hypr/hypridle
      ../../modules/home/hypr/hyprland
      ../../modules/home/hypr/hyprlock
      ../../modules/home/hypr/hyprpaper
      ../../modules/home/swaync
      ../../modules/home/waybar
      ../../modules/home/win2k
      ../../modules/home/wpaperd
    ];

  home = {
    homeDirectory = lib.mkForce "${lib.getHomeDirectory username}";
    stateVersion = "26.05";
    inherit username;
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = true;
    socketActivation.enable = true;
  };
}
