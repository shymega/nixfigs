{
  config,
  lib,
  ...
}: let
  cfg = config.nixfigs.waybar;
in {
  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = import ./waybar-style.nix;
      settings.main = builtins.fromJSON (builtins.readFile ./waybar-config.json);
    };
  };
}
