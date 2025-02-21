# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ self
, inputs
, pkgs ? null
, ...
}:
rec {
  inherit (pkgs.stdenv.hostPlatform)
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
  allSystems = allSystemsAttrs.darwin ++ allSystemsAttrs.linux;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  getHomeDirectory = username: homePrefix + "/${username}";
  isArm = isArmv7 || isAarch64 || isAarch32;
  isForeignNix =
    !isNixOS && isLinux && builtins.pathExists "/nix" && !builtins.pathExists "/etc/nixos";
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
  isPC = isx86_64 || isi686;
  isPCx64 = isx86_64;
  isPCx32 = isi686;
  forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
  homePrefix = if isDarwin then "/Users" else "/home";
  treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
  treeFmtEval = treeFmtEachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ../nix/formatter.nix);
  genPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
  hasRole = r: allRoles:
    builtins.elem r allRoles;
  hasRoles = r: allRoles:
    builtins.all (role: hasRole role allRoles) r;
}
