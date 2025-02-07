# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  modulesPath,
  lib,
  ...
}: {
  imports = ["${modulesPath}/virtualisation/docker-image.nix"];

  boot = {
    isContainer = true;
    loader = {
      grub.enable = lib.mkForce false;
      systemd-boot.enable = lib.mkForce false;
    };
    binfmt.emulatedSystems = [
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"
      "riscv64-linux"
    ];
  };
  services.journald.console = "/dev/console";

  networking.hostName = "build-agent-container";
  users.allowNoPasswordLogin = true;

  system.stateVersion = "24.11";
}
