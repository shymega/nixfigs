{ config, lib, pkgs, ... }:
let
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c sway; swaymsg exit"
    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'
  '';
in {
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    ${pkgs.sway}/bin/sway
    /usr/bin/bash
  '';

  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      libinput.enable = true;
      desktopManager = {
        cinnamon.enable = true;
        plasma5.enable = true;
      };
      windowManager = { awesome.enable = true; };
      layout = "us";
    };
  };
}
