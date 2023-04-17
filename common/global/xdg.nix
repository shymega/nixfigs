{ config, lib, pkgs, ... }: {
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-kde
  ];
}
