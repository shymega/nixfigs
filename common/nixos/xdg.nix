{ config, lib, pkgs, ... }: {
  xdg = {
    portal = {
      enable = true;
    };
    autostart.enable = true;
  };
}
