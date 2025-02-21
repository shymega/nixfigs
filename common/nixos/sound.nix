# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib }: {
  hardware.pulseaudio.enable = lib.mkForce false;

  sound = {
    enable = true;
    mediaKeys = { enable = true; };
  };

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      audio.enable = true;
      pulse.enable = true;
      wireplumber.enable = lib.mkForce true;
      jack.enable = false;
    };
  };
}
