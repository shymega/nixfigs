# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib,  pkgs, ... }:
let
  cfg = config.nixfigs.input.keyboard;
  inherit (pkgs.stdenvNoCC) isLinux;
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
in
with lib;
{
  options = {
    nixfigs.input.keyboard.keychron.enable = mkOption {
      type = with types; bool;
      description = "Enable Linux-specific mitigations for the Keychron keyboard.";
      default = isNixOS;
    };
  };
  config = mkIf cfg.keychron.enable {
    boot.extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
  };
}
