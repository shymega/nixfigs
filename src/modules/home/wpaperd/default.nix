{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.nixfigs.wpaperd;
in {
  config = lib.mkIf cfg.enable {
    services.wpaperd = {
      enable = true;
      settings = {
        default = {
          duration = "15m";
          sorting = "random";
        };
        any = {
          path = "${inputs.nixfigs-wallpapers}/wallpapers/";
        };
      };
    };
  };
}
