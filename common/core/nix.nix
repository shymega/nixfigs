# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs
, lib
, pkgs
, config
, options
, ...
}:
let
  inherit (lib.my) isDarwin isForeignNix isNixOS;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    ../../secrets/system
  ];
  environment.etc."nix/overlays-compat/overlays.nix".text = ''
    final: prev:
    with prev.lib;
    let overlays = builtins.attrValues (builtins.getFlake "path:/etc/nixos").outputs.overlays; in
      foldl' (flip extends) (_: prev) overlays final
  '';

  programs.ssh = {
    extraConfig = ''
      Host eu.nixbuild.net
        HostName eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile ${config.age.secrets.nixbuild_ssh_pub_key.path}
    '';
    knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
  };

  nix =
    {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          sshUser = "${config.networking.hostName}-build-client";
          systems = [ "aarch64-linux" "i686-linux" "armv7-linux" "x86_64-linux" ];
          maxJobs = 2;
          supportedFeatures = [ "benchmark" "big-parallel" ];
          protocol = "ssh-ng";
        }
      ];
      settings = {
        accept-flake-config = true;
        extra-platforms = config.boot.binfmt.emulatedSystems;
        allowed-users = [ "@wheel" ];
        build-users-group = "nixbld";
        builders-use-substitutes = true;
        trusted-users = [
          "root"
          "@wheel"
        ];
        sandbox = isForeignNix || isNixOS;
        substituters = [
          "https://cache.dataaturservice.se/spectrum/"
          "https://cache.nixos.org/"
          "https://deckcheatz-nightlies.cachix.org"
          "https://deploy-rs.cachix.org/"
          "https://devenv.cachix.org"
          "https://nix-community.cachix.org"
          "https://nix-gaming.cachix.org"
          "https://nix-on-droid.cachix.org"
          "https://numtide.cachix.org"
          "https://pre-commit-hooks.cachix.org"

        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "deckcheatz-nightlies.cachix.org-1:ygkraChLCkqqirdkGjQ68Y3LgVrdFB2bErQfj5TbmxU="
          "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
          "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
          "repl-flake"
        ];
        connect-timeout = lib.mkForce 90;
        http-connections = 0;
        warn-dirty = false;
        cores = 0;
        max-jobs = "auto";
        system-features = [
          "kvm"
          "big-parallel"
        ];
        flake-registry = "${inputs.flake-registry}/flake-registry.json";
      };
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
      nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/etc/nix/overlays-compat/" ];
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
    }
    // lib.optionalAttrs (isForeignNix || isNixOS) {
      daemonCPUSchedPolicy = "batch";
      daemonIOSchedPriority = 5;
      gc.dates = "06:00";
    }
    // lib.optionalAttrs isDarwin {
      daemonIOLowPriority = true;
      gc.interval = {
        Hour = 6;
        Minute = 0;
      };
    };
}
