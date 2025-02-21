{ config, ... }:
{
  networking.networkmanager = {
    extraConfig = ''
      [connectivity]
      uri=http://www.archlinux.org/check_network_status.txt
      interval=0
    '';
    dns = "systemd-resolved";
    wifi.macAddress = "stable";
    wifi.powersave = false;
    enable = true;
    dispatcherScripts = [
      {
        source = "/persist/etc/NetworkManager/dispatcher.d/05-wifi-toggle";
        type = "basic";
      }
      {
        source = "/persist/etc/NetworkManager/dispatcher.d/10-net-targets";
        type = "basic";
      }
    ];
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
