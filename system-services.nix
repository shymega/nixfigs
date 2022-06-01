# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  services = {
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    thermald.enable = true;
    openssh = {
      enable = true;
      startWhenNeeded = true;
    };
    udisks2 = { enable = true; };
    printing = { enable = true; };
    avahi = { enable = true; };
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

/*    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
        listen_addresses = [ "127.0.0.1:43" ];

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/ DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key =
            "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      };
    };

    dnsmasq = {
      enable = true;
      servers = [ "127.0.0.1#43" ];
      resolveLocalQueries = true;
    }; */
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
}
