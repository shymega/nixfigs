{ config, lib, ... }: {
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    inputMethod.enabled = "ibus";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
