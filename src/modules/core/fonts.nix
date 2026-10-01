# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.nixfigs.fonts;
  inherit (lib) isLinux;
in
  with lib; {
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
          default = config.nixfigs.fonts.enable;
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
          noto-fonts-color-emoji
          source-code-pro
          terminus_font
          vista-fonts
        ];
      })
      (mkIf (config.nixfigs.fonts.xdg.enable && isLinux) {fonts.fontDir.enable = true;})
    ];
  }
