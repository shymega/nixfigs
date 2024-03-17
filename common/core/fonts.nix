# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  cfg = config.nixfigs.fonts;
  inherit (pkgs.stdenvNoCC) isLinux;
in
with lib;
{
  options = {
    nixfigs.fonts = {
      enable = mkOption {
        type = with types; bool;
        description = "Enables Nix-managed fonts.";
        default = true;
      };
      xdg.enable = mkOption {
        type = with types; bool;
        description = "Enables XDG font symlinking.";
        default = isLinux && config.nixfigs.fonts.enable;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      fonts.packages = with pkgs; [
        corefonts
        fira-code
        fira-code-symbols
        ibm-plex
        jetbrains-mono
        liberation_ttf
        noto-fonts
        noto-fonts-emoji
        source-code-pro
        terminus_font
        vistafonts
      ];
      })
    (mkIf (config.nixfigs.fonts.xdg.enable && isLinux) {
      fonts.fontDir.enable = true;
    })
  ];
}
