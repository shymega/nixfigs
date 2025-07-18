# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  config,
  lib,
  ...
}: {
  # Configure sops-nix for secrets management
  sops = {
    # Default file for secrets
    defaultSopsFile = ../../../secrets/hosts/${config.networking.hostName}/passwords.yaml;
    
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
    
    # Secrets configuration
    secrets = {
      # User password
      "dzrodriguez_password" = {
        neededForUsers = true;
        path = "/run/secrets/dzrodriguez_password";
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };
  };
  
  # Ensure sops key directory exists
  system.activationScripts.sops-nix-setup = ''
    mkdir -p /var/lib/sops-nix
    chown root:root /var/lib/sops-nix
    chmod 700 /var/lib/sops-nix
  '';
}