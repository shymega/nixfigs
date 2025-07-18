# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  config,
  ...
}: let
  cfg = config.nixfigs.isoImage;
in
  with lib; {
    options = {
      nixfigs.isoImage.enable = mkEnableOption "Enable ISO image generation";
    };
    config =
      mkIf cfg.enable {
      };
  }
