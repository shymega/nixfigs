# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD"; # this is important!
    fsType = "ext4";
    options = ["noatime"];
  };

  networking.hostName = "NEO-LINUX"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/London";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users.root = {
    password = "changeme";
  };
  users.ldap = rec {
    enable = true;
    base = "o=644e9696d070741c2aa2bf4f,dc=jumpcloud,dc=com";
    server = "ldap://ldap.jumpcloud.com/";
    useTLS = true;
    bind = {
      distinguishedName = "${builtins.readFile (pkgs.writeText "ldap-bind-dn" "secretsecretsecret")}";
      policy = "soft";
      passwordFile = "${pkgs.writeText "ldap-password" "hunter2"}";
    };
    extraConfig = ''
      ldap_version 3
      pam_password md5

      map passwd loginShell "${pkgs.lib.getExe pkgs.bash}"
    '';
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    tmux
  ];

  programs.mtr.enable = true;
  services.openssh.enable = true;
  services.zerotierone.enable = true;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
