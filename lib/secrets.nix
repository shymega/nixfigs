# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  lib,
}: let
  inherit (lib) mapAttrs' nameValuePair filterAttrs hasAttr pathExists attrNames;
  inherit (builtins) readDir;

  # Create a secrets configuration from discovered files
  mkSecretsConfig = {
    hostname,
    roles,
    secretsInput,
  }: let
    # Determine the primary role for secrets organization
    primaryRole =
      if builtins.elem "work" roles
      then "work"
      else if builtins.elem "personal" roles
      then "personal"
      else "shared";

    # Base secrets path from the input
    secretsPath = "${secretsInput}";

    # Helper to create secret configurations with defaults
    mkSecret = name: file: extraAttrs: {
      ${name} =
        {
          sopsFile = file;
          path = "/run/secrets/${name}";
          mode = "0400";
          owner = "root";
          group = "root";
        }
        // extraAttrs;
    };

    # Discover secrets files for a given path pattern
    discoverSecretsFiles = basePath: let
      fullPath = "${secretsPath}/${basePath}";
    in
      if pathExists fullPath
      then let
        contents = readDir fullPath;
        yamlFiles = filterAttrs (name: type: type == "regular" && lib.hasSuffix ".yaml" name) contents;
      in
        mapAttrs' (filename: _: let
          secretsFile = "${fullPath}/${filename}";
          # Extract base name without .yaml extension
          basename = lib.removeSuffix ".yaml" filename;
        in
          nameValuePair basename secretsFile)
        yamlFiles
      else {};

    # Host-specific secrets discovery
    hostSecrets = discoverSecretsFiles "${primaryRole}/hosts/${hostname}";

    # Shared secrets discovery (for the role)
    sharedSecrets = discoverSecretsFiles "${primaryRole}/shared";

    # Global secrets discovery
    globalSecrets = discoverSecretsFiles "global";

    # Generate secrets configuration from discovered files
    generateSecretsFromFile = secretsFile: basename: let
      # Define common secret patterns and their configurations
      secretPatterns = {
        # Password-related secrets
        passwords = {
          "dzrodriguez_password" = {neededForUsers = true;};
          "workuser-password" = {neededForUsers = true;};
          "luks-password" = {};
          "ssh-host-key" = {};
          "work-email-password" = {};
        };

        # WiFi credentials
        wifi-credentials = {
          "corporate-wifi-psk" = {};
          "guest-wifi-psk" = {};
          "corporate-wifi-cert" = {mode = "0444";};
        };

        # Certificate authorities
        corporate-ca = {
          "corporate-root-ca" = {mode = "0444";};
          "corporate-intermediate-ca" = {mode = "0444";};
          "ldap-ca-cert" = {mode = "0444";};
        };

        # Installer secrets
        config = {
          "installer-ssh-keys" = {};
          "zerotier-network-id" = {};
        };
      };
    in
      if hasAttr basename secretPatterns
      then let
        patterns = secretPatterns.${basename};
      in
        lib.foldl' (acc: secretName: let
          secretConfig = patterns.${secretName};
        in
          acc // (mkSecret secretName secretsFile secretConfig))
        {}
        (attrNames patterns)
      else
        # Fallback: create a single secret with the basename
        mkSecret basename secretsFile {};

    # Combine all discovered secrets
    allSecrets = let
      hostSecretsConfig =
        lib.foldl' (acc: basename: let
          secretsFile = hostSecrets.${basename};
        in
          acc // (generateSecretsFromFile secretsFile basename))
        {}
        (attrNames hostSecrets);

      sharedSecretsConfig =
        lib.foldl' (acc: basename: let
          secretsFile = sharedSecrets.${basename};
        in
          acc // (generateSecretsFromFile secretsFile basename))
        {}
        (attrNames sharedSecrets);

      globalSecretsConfig =
        lib.foldl' (acc: basename: let
          secretsFile = globalSecrets.${basename};
        in
          acc // (generateSecretsFromFile secretsFile basename))
        {}
        (attrNames globalSecrets);
    in
      hostSecretsConfig // sharedSecretsConfig // globalSecretsConfig;

    # Default sops file selection
    defaultSopsFile = let
      passwordsFile = "${primaryRole}/hosts/${hostname}/passwords.yaml";
      fallbackFile = "global/default.yaml";
    in
      if hasAttr "passwords" hostSecrets
      then "${secretsPath}/${passwordsFile}"
      else if pathExists "${secretsPath}/${fallbackFile}"
      then "${secretsPath}/${fallbackFile}"
      else null;
  in {
    inherit allSecrets defaultSopsFile primaryRole;

    # Additional metadata for debugging
    meta = {
      inherit hostname roles secretsPath;
      discoveredFiles = {
        host = hostSecrets;
        shared = sharedSecrets;
        global = globalSecrets;
      };
    };
  };

  # Main function to create sops configuration
  mkSopsConfig = {
    config,
    hostname ? config.networking.hostName,
    roles ? config.nixfigs.meta.rolesEnabled or [],
    secretsInput ? inputs.nixfigs-secrets,
  }: let
    secretsConfig = mkSecretsConfig {
      inherit hostname roles secretsInput;
    };
  in {
    options.nixfigs.secrets = {
      discovery = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Debug information about secrets discovery";
      };
    };

    config = {
      sops = {
        # Use discovered default sops file
        defaultSopsFile = secretsConfig.defaultSopsFile;

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

        # GPG configuration (fallback)
        gnupg = {
          # Use system GPG
          home = "/var/lib/sops-nix/gnupg";

          # Import GPG keys
          sshKeyPaths = ["/etc/ssh/ssh_host_rsa_key"];
        };

        # Auto-discovered secrets
        secrets = secretsConfig.allSecrets;
      };

      # Ensure sops key directory exists
      system.activationScripts.sops-nix-setup = ''
        mkdir -p /var/lib/sops-nix
        chown root:root /var/lib/sops-nix
        chmod 700 /var/lib/sops-nix
      '';

      # Debug information (only in debug builds)
      nixfigs.secrets.discovery = lib.mkIf (config.nixfigs.debug or false) secretsConfig.meta;
    };
  };
in {
  inherit mkSecretsConfig mkSopsConfig;
}
