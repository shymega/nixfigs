{ config, ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [
    {
      source = "/persist/etc/NetworkManager/dispatcher.d/05-wifi-toggle";
      type = "basic";
    }
    {
      source = "/persist/etc/NetworkManager/dispatcher.d/10-net-targets";
      type = "basic";
    }
  ];

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
