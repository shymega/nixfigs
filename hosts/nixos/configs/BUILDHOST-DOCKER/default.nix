# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, ... }:
let
  adminEmail = "shymega2011@gmail.com";
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
in
{
  security.acme = {
    defaults = {
      email = adminEmail;
      dnsProvider = "cloudflare";
      credentialFiles = {
        CLOUDFLARE_API_KEY_FILE = config.age.secrets.cloudflare_dns_token.path;
      };
    };
    acceptTerms = true;
  };

  networking.hostName = "hydra";
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
        {
          hostName = "localhost";
          protocol = null;
          system = "x86_64-linux";
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          maxJobs = 8;
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
