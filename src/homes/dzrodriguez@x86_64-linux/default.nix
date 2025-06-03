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
  imports = with inputs; [
    _1password-shell-plugins.hmModules.default
    shypkgs-public.hmModules.${system}.dwl
    nix-flatpak.homeManagerModules.nix-flatpak
    lix-module.nixosModules.default
    shyemacs-cfg.homeModules.emacs
  ];

  home = {
    homeDirectory = "${lib.getHomeDirectory username}";
    stateVersion = "25.05";
    inherit username;
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = true;
    socketActivation.enable = true;
  };
}
