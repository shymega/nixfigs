{
  config,
  lib,
  ...
}: let
  cfg = config.nixfigs.swaync;
in {
  config = lib.mkIf cfg.enable {
    services.swaync.enable = true;
  };
}
