# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{ config, pkgs, lib, ... }:
{
  services = {
    displayManager.defaultSession = "sway";
    xserver = {
      enable = true;
      displayManager = {
        startx.enable = true;
        gdm = {
          enable = true;
          autoSuspend = false;
        };
      };

      desktopManager = {
        plasma5.enable = true;
        cinnamon.enable = true;
        gnome.enable = true;
      };
      xkb.layout = "us";
    };
    libinput.enable = true;
  };
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR =
    let
      cfg = config.services.xserver.desktopManager.gnome;
      nixos-background-light = pkgs.nixos-artwork.wallpapers.simple-blue;
      nixos-background-dark = pkgs.nixos-artwork.wallpapers.simple-dark-gray;
      flashbackEnabled = cfg.flashback.enableMetacity || lib.length cfg.flashback.customSessions > 0;
      nixos-gsettings-desktop-schemas = pkgs.gnome.nixos-gsettings-overrides.override {
        inherit (cfg) extraGSettingsOverrides extraGSettingsOverridePackages favoriteAppsOverride;
        inherit flashbackEnabled nixos-background-dark nixos-background-light;
      };
    in
    lib.mkForce (pkgs.glib.getSchemaPath nixos-gsettings-desktop-schemas);

  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse.out}/libexec/seahorse/ssh-askpass";
}
