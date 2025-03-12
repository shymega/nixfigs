# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
  ];

  networking.wireless.enable = true;

  boot = {
    loader.generic-extlinux-compatible.enable = true;
    kernelModules = ["i2c-dev"];
  };
  hardware.i2c.enable = true;

  users = {
    extraGroups = {
      gpio = {};
    };
    extraUsers.pi = {
      isNormalUser = true;
      initialPassword = "raspberry";
      extraGroups = [
        "wheel"
        "networkmanager"
        "dialout"
        "gpio"
        "i2c"
      ];
    };
  };
  services = {
    getty.autologinUser = "pi";

    udev = {
      extraRules = ''
        KERNEL=="gpiochip0*", GROUP="gpio", MODE="0660"
      '';
    };
  };
  programs.tmux = {
    enable = true;
    shortcut = lib.mkDefault "b";
    baseIndex = 0;
    keyMode = "emacs";
    secureSocket = false; # Force tmux to use /tmp for sockets (WSL2 compat)

    extraConfig = ''
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';

    clock24 = true;
    historyLimit = 10000;
  };

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = lib.mkForce true;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = lib.mkForce true;
    };
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.sshAgentAuth.enable = true;
}
