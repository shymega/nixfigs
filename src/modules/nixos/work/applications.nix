# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Work-approved applications only
    environment.systemPackages = with pkgs; [
      # Browsers with corporate policies
      firefox
      chromium

      # Office productivity
      libreoffice
      thunderbird

      # Communication
      teams-for-linux
      slack
      zoom-us

      # Development tools (if needed)
      git
      vim
      vscode

      # Security tools
      gnupg
      openssh
    ];

    # Restrict nix package installation for regular users
    nix.settings.allowed-users = ["root"];

    # Disable games and entertainment packages
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "teams-for-linux"
        "slack"
        "zoom"
        "vscode"
        # Add other work-approved unfree packages
      ];
  };
}
