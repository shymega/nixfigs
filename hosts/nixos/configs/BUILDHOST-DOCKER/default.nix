# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, modulesPath, lib, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
in
{
  imports = [
    "${toString modulesPath}/virtualisation/docker-image.nix"
    ../../../../secrets/system
  ];

  boot.isContainer = true;
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  services.journald.console = "/dev/console";

  networking.hostName = "nix-cache";
  networking.domain = "shymega.org.uk";

  services.hydra = {
    enable = true;
    hydraURL = "https://${fqdn}";
    notificationSender = "hydra.no-reply@shymega.org.uk";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };

  programs.ssh = {
    extraConfig = ''
      Host eu.nixbuild.net
        HostName eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
#        IdentityFile ${config.age.secrets.nixbuild_ssh_pub_key.path}
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
    };

  nix = {
    settings.trusted-users = [ "root" "hydra" ];
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
  };

  nix.settings.allowed-uris = [
    "github:"
    "git+https://github.com/"
    "git+ssh://github.com/"
  ];

  system.stateVersion = "24.05";
}
