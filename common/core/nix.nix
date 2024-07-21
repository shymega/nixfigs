# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, lib, pkgs, config, ... }:
let
  inherit (pkgs.stdenvNoCC) isDarwin;
  inherit (pkgs.stdenvNoCC) isLinux;
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
  isForeignNix = !isNixOS && isLinux && builtins.pathExists "/nix";
in
{
  nix = {
    settings = {
      accept-flake-config = true;
      extra-platforms = config.boot.binfmt.emulatedSystems;
      allowed-users = [ "@wheel" ];
      build-users-group = "nixbld";
      builders-use-substitutes = true;
      trusted-users = [ "root" "@wheel" ];
      sandbox = isForeignNix || isNixOS;
      substituters = [
        "https://arm.cachix.org/"
        "https://cache.dataaturservice.se/spectrum"
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://nix-on-droid.cachix.org"
        "https://pre-commit-hooks.cachix.org"
      ];
      trusted-public-keys = [
        "arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        "spectrum-os.org-1:rnnSumz3+Dbs5uewPlwZSTP0k3g/5SRG4hD7Wbr9YuQ="
      ];
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      connect-timeout = lib.mkForce 90;
      http-connections = 0;
      warn-dirty = false;
      cores = 0;
      max-jobs = "auto";
      system-features = [ "kvm" "big-parallel" ];
    };
    distributedBuilds = true;
    extraOptions = ''
      gc-keep-outputs = false
      gc-keep-derivations = false
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
    package = pkgs.nixFlakes;
    registry.nixpkgs.flake = inputs.nixpkgs;
    optimise = {
      automatic = true;
      dates = [ "06:00" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  } // lib.optionalAttrs (isForeignNix || isNixOS)
    {
      daemonCPUSchedPolicy = "batch";
      daemonIOSchedPriority = 5;
      gc.dates = "06:00";
    } // lib.optionalAttrs isDarwin {
    daemonIOLowPriority = true;
    gc.interval = { Hour = 6; Minute = 0; };
  };
}
