# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
rec {
  roles = [
    "clockworkpi-dev"
    "clockworkpi-prod"
    "container"
    "darwin"
    "darwin-arm64"
    "darwin-x86"
    "embedded"
    "gaming"
    "github-runner"
    "gitlab-runner"
    "gpd-duo"
    "gpd-wm2"
    "jovian"
    "minimal"
    "mobile-nixos"
    "nix-on-droid"
    "personal"
    "proxmox-lxc"
    "proxmox-vm"
    "raspberrypi-arm64"
    "raspberrypi-zero"
    "rnet"
    "shynet"
    "steam-deck"
    "work"
    "workstation"
    "wsl"
  ];
  utils = rec {
    checkRole = role: (builtins.elem role roles);
    checkRoleIn = targetRole: hostRoles:
      (builtins.elem targetRole roles) && (builtins.elem targetRole hostRoles);
    checkRoles = targetRoles: hostRoles: (builtins.any checkRole targetRoles) && (builtins.any checkRole hostRoles);
    checkAllRoles = targetRoles: hostRoles: (builtins.all checkRole targetRoles) && (builtins.all checkRole hostRoles);
  };
}
