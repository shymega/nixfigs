{ config, lib, pkgs, ... }: {
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
}
