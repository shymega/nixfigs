# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, system, ... }:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
  };
  inherit (pkgs) lib;
in
{
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
  ];

  formatConfigs.proxmox-lxc = {
    proxmoxLXC.manageHostName = true;
  };

  formatConfigs.docker = {
    networking.firewall.enable = lib.mkForce false;
    services.fail2ban.enable = lib.mkForce false;
    services.openssh.startWhenNeeded = lib.mkForce false;
  };

  nixpkgs.hostPlatform = system;
}
