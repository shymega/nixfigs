# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  self,
  inputs,
  pkgs ? inputs.nixpkgs.legacyPackages.x86_64-linux,
  ...
}: let
  rolesModule = import ../nix-support/roles.nix;
in rec {
  inherit (rolesModule) roles;
  inherit (rolesModule.utils) checkRole checkRoleIn checkRoles checkAllRoles;
  inherit
    (pkgs.stdenv.hostPlatform)
    isLinux
    isDarwin
    isx86_64
    isi686
    isArmv7
    isRiscV64
    isRiscV32
    isAarch64
    isAarch32
    ;
  inherit (pkgs.lib.strings) hasSuffix;
  inherit (pkgs.lib) genAttrs;
  allLinuxSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];
  allDarwinSystems = [
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  allSystemsAttrs = {
    linux = allLinuxSystems;
    darwin = allDarwinSystems;
  };
  allSystems = allLinuxSystems ++ allDarwinSystems;
  defaultSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  getHomeDirectory = username: homePrefix + "/${username}";
  isArm = isArmv7 || isAarch64 || isAarch32;
  isForeignNix =
    !isNixOS && isLinux && builtins.pathExists "/nix" && !builtins.pathExists "/etc/nixos";
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
  isPC = isx86_64 || isi686;
  isPC64 = isx86_64;
  isPC32 = isi686;
  isDarwinArm = pkgs.system == "aarch64-darwin";
  isDarwinx86 = pkgs.system == "x86_64-darwin";
  forEachSystem = genAttrs defaultSystems;
  forAllEachSystems = genAttrs allSystems;
  homePrefix =
    if isDarwin
    then "/Users"
    else "/home";
  genPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
}
