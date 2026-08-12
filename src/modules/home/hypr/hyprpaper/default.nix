{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.nixfigs.hypr.hyprpaper;
in {
  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      package = pkgs.hyprpaper;
      settings = {
        splash = false;
        wallpaper = [
          {
            monitor = "";
            path = "${inputs.nixfigs-wallpapers}/wallpapers/";
          }
        ];
      };
    };
  };
}
