{ config, pkgs, ... }:
{
  security.pam.u2f = {
    enable = true;
    cue = true;
  };
  services.udev.packages = with pkgs.unstable; [
    solo2-cli
  ];
}
