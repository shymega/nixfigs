{ config, lib, pkgs, ... }: {
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
    autostart.enable = true;
  };
}
