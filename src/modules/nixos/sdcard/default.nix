# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  config,
  ...
}: let
  cfg = config.nixfigs.sdImage;
in
  with lib; {
    options = {
      nixfigs.sdImage.enable = mkEnableOption "Enable SD card image generation";
    };
    config =
      mkIf cfg.enable {
      };
  }
