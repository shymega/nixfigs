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
    "personal"
    "proxmox-lxc"
    "proxmox-vm"
    "raspberrypi-arm64"
    "raspberrypi-zero"
    "rnet"
    "shynet"
    "work"
    "workstation"
    "wsl"
  ];
  utils = rec {
    checkRoles =
      targetRoles: configOrHostRoles:
      let
        # Private helper function
        checkRole = role: (builtins.elem role roles);

        # Normalize target roles to list
        rolesList = if builtins.isList targetRoles then targetRoles else [ targetRoles ];

        # Auto-detect if second argument is config (attrset with nixfigs) or hostRoles (list)
        isConfig = builtins.isAttrs configOrHostRoles;

        enabledRoles = if isConfig then configOrHostRoles.nixfigs.meta.rolesEnabled else configOrHostRoles; # treat as hostRoles list
      in
      # Check if any target role is valid AND any target role is enabled
      (builtins.any checkRole rolesList)
      && (builtins.any (role: builtins.elem role enabledRoles) rolesList);
  };
}
