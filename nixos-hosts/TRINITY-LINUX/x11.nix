{ config, lib, pkgs, ... }:
let
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    output DSI-1 scale 1.30 transform 90
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c sway; swaymsg exit"
    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot' \
      -b 'Suspend' 'systemctl suspend'
  '';
in
{
  services.greetd = {
    enable = false;
    restart = false;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    sway
    startplasma-x11
    startplasma-wayland
    cinnamon-session
    awesome
  '';

  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      displayManager = {
        gdm.enable = true;
        defaultSession = "sway";
      };
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
