# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  enabledByRole = checkRoles ["personal" "work" "workstation"] config;
in {
  options.nixfigs.input.keyboard.keychron.enable = mkOption {
    type = types.bool;
    description = "Enable Linux-specific mitigations for the Keychron keyboard.";
    default = enabledByRole;
  };
  config = mkIf config.nixfigs.input.keyboard.keychron.enable {
    boot.extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
    environment.systemPackages = with pkgs; [
      via
    ];
    services.udev.packages = [pkgs.via];
    hardware.keyboard.qmk.enable = true;
  };
}
