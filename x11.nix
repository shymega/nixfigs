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
    /usr/local/bin/sway-launch
    /usr/bin/bash
    /usr/local/bin/awesome-launch
    /usr/local/bin/cinnamon-launch
    /usr/local/bin/kde-wayland-launch
    /usr/local/bin/kde-x11-launch
    /usr/local/bin/stumpwm-x11-launch
  '';

  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      libinput.enable = true;
      desktopManager = {
        cinnamon.enable = true;
        plasma5.enable = false;
      };
      windowManager = { awesome.enable = true; };
      layout = "us";
    };
  };
}
