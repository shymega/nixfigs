{
  lib,
  config,
  ...
}: {
  options.nixfigs = {
    hypr = {
      hyprland.enable = lib.mkEnableOption "the Hyprland window manager";

      hypridle.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.nixfigs.hypr.hyprland.enable;
        description = "Whether to enable hypridle.";
      };

      hyprlock.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.nixfigs.hypr.hypridle.enable;
        description = "Whether to enable hyprlock.";
      };

      hyprpaper.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.nixfigs.hypr.hyprland.enable && !config.nixfigs.wpaperd.enable;
        description = "Whether to enable hyprpaper. Disabled by default when wpaperd is enabled, since they serve the same purpose.";
      };
    };

    waybar.enable = lib.mkEnableOption "Waybar";
    swaync.enable = lib.mkEnableOption "SwayNotificationCenter";
    wpaperd.enable = lib.mkEnableOption "wpaperd";

    # Windows 2000 (Luna) desktop theme, provided by the hypr-dotw2k flake
    # input. Overrides Hyprland decoration, waybar, swaync, GTK/Qt/icons/
    # cursor/font, and rofi.
    win2k.enable = lib.mkEnableOption "the Windows 2000 (Luna) theme (via hypr-dotw2k)";
  };
}
