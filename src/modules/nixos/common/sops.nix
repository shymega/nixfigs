# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  config,
  lib,
  ...
}:
let
  inherit (config.nixfigs.roles) checkRoles;
  isWork = checkRoles ["work"] config;
  isPersonal = checkRoles ["personal"] config;
  hostname = config.networking.hostName;
in {
  # Configure sops-nix for secrets management
  sops = {
    # Role-based default secrets file
    defaultSopsFile = 
      if isWork then ../../../secrets/work/hosts/${hostname}/passwords.yaml
      else if isPersonal then ../../../secrets/personal/hosts/${hostname}/passwords.yaml
      else ../../../secrets/hosts/${hostname}/passwords.yaml; # Fallback for other roles
    
    # Validate sops files at build time
    validateSopsFiles = true;
    
    # Use age for decryption
    age = {
      # Use SSH host key for decryption
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      
      # Generate age key from SSH host key
      generateKey = true;
      
      # Key file location
      keyFile = "/var/lib/sops-nix/key.txt";
    };
    
    # GPG configuration
    gnupg = {
      # Use system GPG
      home = "/var/lib/sops-nix/gnupg";
      
      # Import GPG keys
      sshKeyPaths = ["/etc/ssh/ssh_host_rsa_key"];
    };
    
    # Role-based secrets configuration
    secrets = 
      if isWork then {
        # Work-specific secrets
        "workuser-password" = {
          neededForUsers = true;
          path = "/run/secrets/workuser-password";
          mode = "0400";
          owner = "root";
          group = "root";
        };
        "luks-password" = {
          path = "/run/secrets/luks-password";
          mode = "0400";
          owner = "root";
          group = "root";
        };
        "work-wifi-psk" = {
          sopsFile = ../../../secrets/work/hosts/${hostname}/wifi-credentials.yaml;
          path = "/run/secrets/work-wifi-psk";
          mode = "0400";
          owner = "root";
          group = "root";
        };
        "corporate-root-ca" = {
          sopsFile = ../../../secrets/work/shared/corporate-ca.yaml;
          path = "/run/secrets/corporate-root-ca";
          mode = "0444";
          owner = "root";
          group = "root";
        };
      }
      else if isPersonal then {
        # Personal secrets (existing configuration)
        "dzrodriguez_password" = {
          neededForUsers = true;
          path = "/run/secrets/dzrodriguez_password";
          mode = "0400";
          owner = "root";
          group = "root";
        };
      }
      else {}; # No secrets for other roles
  };
  
  # Ensure sops key directory exists
  system.activationScripts.sops-nix-setup = ''
    mkdir -p /var/lib/sops-nix
    chown root:root /var/lib/sops-nix
    chmod 700 /var/lib/sops-nix
  '';
}