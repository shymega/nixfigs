{ config, lib, pkgs, ... }: {
  hardware.pulseaudio.enable = false;

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
      pulse.enable = true;
      jack.enable = false;
    };
  };
}
