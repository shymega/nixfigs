# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{
  inputs,
  hostPlatform,
  ...
}: let
  pkgs = import inputs.nixpkgs {inherit hostPlatform;};
  inherit (pkgs) lib;
in {
  imports = [inputs.nixos-generators.nixosModules.all-formats];

  formatConfigs.proxmox-lxc = {
    proxmoxLXC.manageHostName = true;
  };

  formatConfigs.docker = {
    networking.firewall.enable = lib.mkForce false;
    services.fail2ban.enable = lib.mkForce false;
    services.openssh.startWhenNeeded = lib.mkForce false;
  };

  nixpkgs.hostPlatform = hostPlatform;
}
