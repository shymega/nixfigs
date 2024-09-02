# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ modulesPath, lib, ... }:
{
  imports = [
    "${toString modulesPath}/virtualisation/docker-image.nix"
  ];

  boot = {
    isContainer = true;
    loader = {
      grub.enable = lib.mkForce false;
      systemd-boot.enable = lib.mkForce false;
    };
  };
  services.journald.console = "/dev/console";

  networking.hostName = "BUILDER-CONTAINER";

  system.stateVersion = "24.05";

}
