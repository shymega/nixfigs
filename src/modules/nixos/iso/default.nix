# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.nixfigs.isoImage;
  isWork = builtins.elem "work" (config.nixfigs.hostRoles or []);
  isPersonal = builtins.elem "personal" (config.nixfigs.hostRoles or []);
in
  with lib; {
    options = {
      nixfigs.isoImage = {
        enable = mkEnableOption "Enable ISO image generation";
        
        isoName = mkOption {
          type = types.str;
          default = "nixos-installer";
          description = "Name of the ISO image";
        };

        includeZeroTier = mkOption {
          type = types.bool;
          default = true;
          description = "Include ZeroTier One for network connectivity";
        };

        includeZFS = mkOption {
          type = types.bool;
          default = true;
          description = "Include ZFS support";
        };

        sshKeys = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "SSH public keys to include in the installer";
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [];
          description = "Additional packages to include in the ISO";
        };
      };
    };
    
    config = mkIf cfg.enable {
      isoImage.isoName = cfg.isoName;
      
      # Enable systemd in stage 1
      boot.initrd.systemd.enable = true;
      
      # ZFS support
      boot.supportedFilesystems = mkIf cfg.includeZFS ["zfs"];
      boot.zfs.forceImportAll = mkIf cfg.includeZFS true;
      
      # Network configuration
      networking.useDHCP = lib.mkDefault true;
      networking.useNetworkd = true;
      systemd.network.enable = true;
      
      # ZeroTier configuration
      services.zerotierone = mkIf cfg.includeZeroTier {
        enable = true;
        joinNetworks = mkIf (config.sops.secrets ? "zerotier-network-id") [
          "$(cat ${config.sops.secrets."zerotier-network-id".path})"
        ];
      };

      # SOPS secrets configuration for installer
      sops = mkIf (isPersonal && (cfg.includeZeroTier || cfg.sshKeys == [])) {
        defaultSopsFile = ../../../secrets/personal/installer/config.yaml;
        secrets = {
          "zerotier-network-id" = mkIf cfg.includeZeroTier {
            mode = "0444";
            owner = "root";
            group = "root";
          };
          "installer-ssh-keys" = mkIf (cfg.sshKeys == []) {
            mode = "0444";
            owner = "root";
            group = "root";
          };
        };
      };
      
      # SSH configuration
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };
      
      # User configuration
      users.users.installer = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
        openssh.authorizedKeys.keys = cfg.sshKeys;
        openssh.authorizedKeys.keyFiles = mkIf (cfg.sshKeys == [] && (config.sops.secrets ? "installer-ssh-keys")) [
          config.sops.secrets."installer-ssh-keys".path
        ];
        shell = pkgs.fish;
      };
      
      users.users.root = {
        openssh.authorizedKeys.keys = cfg.sshKeys;
        openssh.authorizedKeys.keyFiles = mkIf (cfg.sshKeys == [] && (config.sops.secrets ? "installer-ssh-keys")) [
          config.sops.secrets."installer-ssh-keys".path
        ];
      };
      
      # Essential packages for installer
      environment.systemPackages = with pkgs; [
        # ZFS utilities
        zfs
        # Network tools
        curl
        wget
        # Text editors
        vim
        nano
        # System tools
        htop
        tree
        lsof
        # Git for cloning configurations
        git
        # Partition tools
        gptfdisk
        parted
        # Archive tools
        unzip
        # Fish shell
        fish
      ] ++ cfg.extraPackages;
      
      # Enable fish shell
      programs.fish.enable = true;
      
      # Console configuration
      console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
      };
      
      # Locale settings
      i18n.defaultLocale = "en_US.UTF-8";
      
      # Time zone
      time.timeZone = "UTC";
      
      # Enable flakes
      nix.settings.experimental-features = ["nix-command" "flakes"];
      
      # Auto-login for installer user
      services.getty.autologinUser = "installer";
      
      # Welcome message
      environment.etc."issue".text = ''
        NixOS Installer ISO
        ===================
        
        Welcome to the NixOS installer environment!
        
        This system includes:
        - ZFS support for advanced storage management
        - ZeroTier for network connectivity
        - SSH access with pre-configured keys
        - Essential system administration tools
        
        To get started:
        1. Configure your network connection
        2. Partition your disks (ZFS recommended)
        3. Mount your filesystems
        4. Install NixOS
        
        For help: man nixos-install
        
      '';
      
      # Disable sudo password for installer user
      security.sudo.wheelNeedsPassword = false;
    };
  }
