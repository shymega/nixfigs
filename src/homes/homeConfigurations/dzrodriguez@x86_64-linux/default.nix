# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  pkgs,
  inputs,
  system,
  self,
  config,
  username,
  osConfig ? {},
  ...
} @ args: let
  isOsModule = builtins.hasAttr "config" osConfig;
in {
  disabledModules = [
    "services/window-managers/hyprland.nix"
  ];

  imports = with inputs; [
    "${self}/src/modules/home/hyprland"
    _1password-shell-plugins.hmModules.default
    shypkgs-public.hmModules.${system}.dwl
    nix-flatpak.homeManagerModules.nix-flatpak
    lix-module.nixosModules.default
    shyemacs-cfg.homeModules.emacs
  ];

  home = {
    homeDirectory = "${lib.getHomeDirectory username}";
    # homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    inherit username;
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = true;
    socketActivation.enable = true;
  };
}
