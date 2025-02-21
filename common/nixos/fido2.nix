{ config, pkgs, ... }:
{
  security.pam.u2f = {
    enable = true;
    cue = true;
  };
  services.udev.packages = with pkgs; [
    solo2-cli
  ];
}
