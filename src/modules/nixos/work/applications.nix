# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Work-approved applications only
    environment.systemPackages = with pkgs; [
      # Browsers with corporate policies
      firefox
      chromium
      
      # Office productivity
      libreoffice
      thunderbird
      
      # Communication
      teams-for-linux
      slack
      zoom-us
      
      # Development tools (if needed)
      git
      vim
      vscode
      
      # Security tools
      gnupg
      openssh
    ];

    # Corporate browser policies
    programs.firefox = {
      enable = true;
      policies = {
        DisablePrivateBrowsing = false; # Allow private browsing
        DisableProfileImport = true;
        DontCheckDefaultBrowser = true;
        Homepage.URL = "https://www.google.com"; # Replace with corporate intranet
        
        # Corporate security extensions (add as needed)
        ExtensionSettings = {
          # uBlock Origin for security
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    # Restrict nix package installation for regular users
    nix.settings.allowed-users = [ "root" ];
    
    # Disable games and entertainment packages
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "teams-for-linux"
      "slack"
      "zoom"
      "vscode"
      # Add other work-approved unfree packages
    ];
  };
}