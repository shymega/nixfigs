# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ inputs
, lib
, pkgs
, hostname
, ...
}:
{
  imports =
    [
      ./bluetooth.nix
      ./custom-systemd-units
      ./dovecot2.nix
      ./fido2.nix
      ./firmware.nix
      ./inst_packages.nix
      ./kernel_params.nix
      ./keychron.nix
      ./sound.nix
      ./steam-hardware.nix
      ./systemd-initrd.nix
      ./utils
      ./xdg.nix
      inputs.agenix.nixosModules.age
    ]
    ++ (
      if hostname == "NEO-LINUX" || hostname == "MORPHEUS-LINUX" || hostname == "TWINS-LINUX" then
        [
          ./appimage.nix
          ./fido2.nix
          ./graphical.nix
          ./impermanence.nix
          ./keychron.nix
          ./networking.nix
          ./postfix.nix
          ./steam-hardware.nix
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.nix-index-database.nixosModules.nix-index
          inputs.stylix.nixosModules.stylix
        ]
      else
        [ ]
    );

  boot.kernelParams = [ "log_buf_len=10M" ];

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
  };

  i18n.defaultLocale = "en_GB.UTF-8";

  networking = {
    firewall = {
      #      trustedInterfaces = [ "tailscale0" ];
      #      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  programs = {
    command-not-found.enable = false;
    mosh.enable = true;
    zsh.enableGlobalCompInit = false;
  };

  security = {
    pam.services.sudo.u2fAuth = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  services = {
    dbus.implementation = "broker";
    openssh = {
      enable = true;
      settings.PermitRootLogin = lib.mkDefault "no";
    };
    tailscale.enable = true;
  };

  system = {
    extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';
  };

  systemd = {
    network.wait-online.anyInterface = true;
    services.tailscaled = {
      after = [
        "network-online.target"
      ];
      wants = [
        "network-online.target"
      ];
    };
  };

  users.mutableUsers = false;
}
