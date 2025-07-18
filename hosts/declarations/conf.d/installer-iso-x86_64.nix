# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  mkHost,
  inputs,
  ...
}: mkHost {
    type = "nixos";
    hostname = "installer-iso-x86_64";
    hostPlatform = "x86_64-linux";
    hostRoles = ["installer" "personal"];
    
    hardwareModules = with inputs; [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
    ];
    
    pubkey = null;
    embedHm = false;
    remoteBuild = false;
    deployable = false;
  }
