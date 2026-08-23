{
  config ? {},
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.nixfigs.email ? osConfig.nixfigs.email;
  enabled = cfg.enable && (cfg.accounts != []);
in {
  config = mkIf enabled {};
}
