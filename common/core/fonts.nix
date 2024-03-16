# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib, config, pkgs, ... }:
let
  inherit (pkgs.stdenvNoCC) isLinux;
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
in
{
  options = {
    nixfigs.fonts = {
      managed.enable = mkOption {
        type = bool;
        description = "Whenever to enable 'managed fonts'.";
        default = true;
      };
      xdg.enable = mkOption {
        type = bool;
        description = "Enables XDG font symlinking.";
        default = isLinux;
      };
    };
  };

  config = mkIf config.nixfigs.fonts.managed.enable
    {
      fonts.packages = with pkgs.unstable; [
        corefonts
        ibm-plex
        jetbrains-mono
        source-code-pro
      ];
    }
  // mkIf (config.nixfigs.fonts.xdg.enable && isLinux) {
    fonts.fontDir.enable = true;
  };
}
