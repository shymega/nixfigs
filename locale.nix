{ config, pkgs, lib, ... }:

{
  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    inputMethod = { enabled = "ibus"; };
  };
}
