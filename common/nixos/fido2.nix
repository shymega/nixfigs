# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, lib, ... }:
{
  security.pam = {
    services = {
      login.u2fAuth = false;
      sudo.u2fAuth = lib.mkForce false;
    };

    u2f = {
      enable = false;
      cue = false;
      control = "sufficient";
    };
  };

  services.pcscd.enable = false;

  services.udev = {
    packages = with pkgs; [ yubikey-personalization solo2-cli ];
    extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };
}
