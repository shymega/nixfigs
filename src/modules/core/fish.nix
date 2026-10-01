# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
in {
  options = {
    nixfigs.shells.fish = {
      enable = mkOption {
        type = bool;
        description = "Enables the Fish shell.";
        default = false;
      };
      allConf = mkOption {
        type = bool;
        description = "Enables all configuration for the Fish shell.";
        default = config.nixfigs.shells.fish.enable;
      };
    };
  };

  config = mkIf config.nixfigs.shells.fish.enable {
    programs.fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
  };
}
