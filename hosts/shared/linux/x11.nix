{ config, ... }: {
  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      displayManager = {
        gdm.enable = true;
        gdm.autoSuspend = false;
        defaultSession = "sway";
      };
      libinput.enable = true;
      desktopManager = {
        cinnamon.enable = true;
        plasma5.enable = true;
      };
      windowManager = {
        awesome.enable = true;
        stumpwm.enable = true;
        i3.enable = true;
      };
      layout = "us";
    };
  };
}