# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  config,
  lib,
  ...
}:
let
  inherit (lib) checkRoles;
  isWork = checkRoles ["work"] config;
  isPersonal = checkRoles ["personal"] config;
  hostname = config.networking.hostName;

  # Helper to create secret configurations with defaults
  mkSecret = name: file: extraAttrs: {
    ${name} = {
      sopsFile = file;
      path = "/run/secrets/${name}";
      mode = "0400";
      owner = "root";
      group = "root";
    } // extraAttrs;
  };

  # Auto-generated secrets based on known secret names from YAML files
  # This avoids the need to parse YAML at build time
  workSecrets = 
    # From passwords.yaml
    (mkSecret "workuser-password" ../../../secrets/work/hosts/${hostname}/passwords.yaml { neededForUsers = true; }) //
    (mkSecret "luks-password" ../../../secrets/work/hosts/${hostname}/passwords.yaml {}) //
    (mkSecret "ssh-host-key" ../../../secrets/work/hosts/${hostname}/passwords.yaml {}) //
    (mkSecret "work-email-password" ../../../secrets/work/hosts/${hostname}/passwords.yaml {}) //
    
    # From wifi-credentials.yaml  
    (mkSecret "corporate-wifi-psk" ../../../secrets/work/hosts/${hostname}/wifi-credentials.yaml {}) //
    (mkSecret "guest-wifi-psk" ../../../secrets/work/hosts/${hostname}/wifi-credentials.yaml {}) //
    (mkSecret "corporate-wifi-cert" ../../../secrets/work/hosts/${hostname}/wifi-credentials.yaml { mode = "0444"; }) //
    
    # From shared corporate-ca.yaml
    (mkSecret "corporate-root-ca" ../../../secrets/work/shared/corporate-ca.yaml { mode = "0444"; }) //
    (mkSecret "corporate-intermediate-ca" ../../../secrets/work/shared/corporate-ca.yaml { mode = "0444"; }) //
    (mkSecret "ldap-ca-cert" ../../../secrets/work/shared/corporate-ca.yaml { mode = "0444"; });

  personalSecrets = 
    # From passwords.yaml
    (mkSecret "dzrodriguez_password" ../../../secrets/personal/hosts/${hostname}/passwords.yaml { neededForUsers = true; });

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
    
    # Role-based secrets configuration - auto-generated from YAML files
    secrets = 
      if isWork then workSecrets
      else if isPersonal then personalSecrets  
      else {}; # No secrets for other roles
  };
  
  # Ensure sops key directory exists
  system.activationScripts.sops-nix-setup = ''
    mkdir -p /var/lib/sops-nix
    chown root:root /var/lib/sops-nix
    chmod 700 /var/lib/sops-nix
  '';
}