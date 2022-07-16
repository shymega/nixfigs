{ config, pkgs, lib, ... }:

{
  time.timeZone = "Europe/London";

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    inputMethod = { enabled = "ibus"; };
  };
}
