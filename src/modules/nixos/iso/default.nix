# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.nixfigs.installer;
  isWork = builtins.elem "work" (config.nixfigs.hostRoles or []);
  isPersonal = builtins.elem "personal" (config.nixfigs.hostRoles or []);
  
  # Determine architecture-specific settings
  isAarch64 = config.nixpkgs.hostPlatform.isAarch64;
  isX86_64 = config.nixpkgs.hostPlatform.isx86_64;
  
  # Auto-detect output format based on configuration options
  hasIsoModule = config ? isoImage;
  hasSdModule = config ? sdImage;
  
  # Determine output format implicitly
  outputFormat = if hasIsoModule && hasSdModule then "both"
                else if hasIsoModule then "iso"
                else if hasSdModule then "sd-card"
                else "iso"; # fallback
  
  # Common packages for all architectures
  commonPackages = with pkgs; [
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
  ];
  
  # Architecture-specific packages
  archPackages = with pkgs; if isAarch64 then [
    # ARM-specific tools
    dtc
    u-boot-tools
    lshw
    smartmontools
  ] else if isX86_64 then [
    # x86_64-specific tools
    dmidecode
    pciutils
    usbutils
    lshw
    smartmontools
    nvme-cli
  ] else [];
in
  with lib; {
    options = {
      nixfigs.installer = {
        enable = mkEnableOption "Enable installer image generation";
        
        imageName = mkOption {
          type = types.str;
          default = "nixos-installer";
          description = "Name of the installer image";
        };


        bootMode = mkOption {
          type = types.enum ["bios" "uefi" "both"];
          default = "both";
          description = "Boot mode support for ISO: bios, uefi, or both";
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
          description = "Additional packages to include in the installer";
        };

        # SD card specific options
        sdCard = {
          populateRootCommands = mkOption {
            type = types.lines;
            default = "";
            description = "Commands to populate the root filesystem on SD card";
          };

          populateFirmwareCommands = mkOption {
            type = types.lines;
            default = "";
            description = "Commands to populate the firmware partition on SD card";
          };

          firmwareSize = mkOption {
            type = types.int;
            default = 128;
            description = "Size of the firmware partition in MB";
          };
        };
      };
    };
    
    config = mkIf cfg.enable (mkMerge [
      {
        # Common installer configuration
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
        environment.systemPackages = commonPackages ++ archPackages ++ cfg.extraPackages;
        
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
          NixOS Installer (${outputFormat})
          ======================${lib.stringAsChars (x: "=") outputFormat}
          
          Welcome to the NixOS installer environment!
          
          This system includes:
          - ZFS support for advanced storage management
          - ZeroTier for network connectivity
          - SSH access with pre-configured keys
          - Essential system administration tools
          
          Architecture: ${config.nixpkgs.hostPlatform.system}
          Output format: ${outputFormat}
          ${lib.optionalString (outputFormat == "iso" || outputFormat == "both") "Boot mode: ${cfg.bootMode}"}
          
          To get started:
          1. Configure your network connection
          2. Partition your disks (ZFS recommended)
          3. Mount your filesystems
          4. Install NixOS
          
          For help: man nixos-install
          
        '';
        
        # Disable sudo password for installer user
        security.sudo.wheelNeedsPassword = false;
        
        # Architecture-specific configurations
        boot.kernelParams = mkMerge [
          (mkIf isAarch64 [
            "console=ttyS0,115200n8"
            "console=tty0"
            "earlycon"
          ])
          (mkIf isX86_64 [
            "console=ttyS0,115200n8"
            "console=tty0"
          ])
        ];
        
        # Enable hardware support
        hardware.enableAllFirmware = true;
        hardware.enableRedistributableFirmware = true;
        
        # Network interface naming
        networking.usePredictableInterfaceNames = true;
      }
      
      # Configure ISO image options if the module is available
      (mkIf hasIsoModule {
        isoImage = {
          isoName = cfg.imageName;
          # Boot mode configuration
          makeEfiBootable = mkIf (cfg.bootMode == "uefi" || cfg.bootMode == "both") true;
          makeUsbBootable = mkIf (cfg.bootMode == "bios" || cfg.bootMode == "both") true;
          # Volume label
          volumeLabel = "NIXOS_INSTALLER";
        };
      })
      
      # Configure SD card options if the module is available
      (mkIf hasSdModule {
        sdImage = {
          imageName = cfg.imageName;
          populateRootCommands = cfg.sdCard.populateRootCommands;
          populateFirmwareCommands = cfg.sdCard.populateFirmwareCommands;
          firmwareSize = cfg.sdCard.firmwareSize;
          # Ensure we have space for the installer and tools
          rootPartitionUUID = "44444444-4444-4444-8888-888888888888";
          compressImage = true;
        };
      })
    ]);
  }
