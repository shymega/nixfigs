{ config, lib, pkgs, inputs, ... }:

{
  users.users.dzrodriguez = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "RODRIGUEZ, Dom";
    password = "password";
    subUidRanges = [{
      startUid = 100000;
      count = 65536;
    }];
    subGidRanges = [{
      startGid = 100000;
      count = 65536;
    }];
    extraGroups = [
      "wheel"
      "dialout"
      "adbusers"
      "uucp"
      "kvm"
      "docker"
      "libvirt"
      "lp"
      "lpadmin"
      "plugdev"
      "input"
      "disk"
      "networkmanager"
      "video"
      "qemu-libvirtd"
      "libvirtd"
      "systemd-journal"
    ];
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # Very dodgy!
  };

  services = {
    avahi.enable = true;
    flatpak.enable = true;
    thermald.enable = true;
    dbus.enable = true;
    openssh = {
      enable = true;
      startWhenNeeded = true;
    };
    udisks2.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    blueman.enable = true;
    zerotierone.enable = true;
    power-profiles-daemon.enable = false;
    geoclue2.enable = true;

    resolved = {
      enable = true;
      dnssec = "true";
      dns = [
      ];
      fallbackDns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
      extraConfig = ''
        DNSOverTLS=yes
        DNS=1.1.1.1#one.one.one.one 1.0.0.1#one.one.one.one 9.9.9.9#dns.quad9.net
      '';
    };
  };

  networking.networkmanager.dns = "systemd-resolved";

  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.adb.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  virtualisation.podman.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.lxd.enable = true;
  environment.shells = with pkgs; [ zsh fish ];

  system.autoUpgrade.enable = true;

  nix.settings.auto-optimise-store = true;
}
