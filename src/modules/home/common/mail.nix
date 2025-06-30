{
  osConfig ? {},
  config ? {},
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.nixfigs.email ? osConfig.nixfigs.email;
  enabled = cfg.enable && (cfg.accounts != []);

  emailAccount = {name, ...}: {
    options = rec {
      name = mkOption {
        type = types.str;
        readOnly = true;
      };
      enable = mkEnableOption {
        default = true;
      };
      enabledMuas = mkOption {
        type = with types; listOf str;
        default = [
          "neomutt"
        ];
      };
      realName = mkOption {
        type = types.str;
      };
      replyTo = mkOption {
        type = types.str;
        default = fromAddress;
      };
      fromAddress = mkOption {
        type = types.str;
      };
      userName = mkOption {
        type = types.str;
        default = fromAddress;
      };
      davmail = mkEnableOption {
        default = false;
      };
      mailServer = mkOption {
        type = types.str;
      };
      enableIdle = mkEnableOption {
        default = false;
      };
      emailSignature = mkOption {
        type = types.str;
      };
      neomutt = {
        enable = mkEnableOption {
          default = elem "neomutt" enabledMuas;
        };
        extraConfig = mkOption {
          type = types.attrs;
          description = "Any extra configuration for Neomutt";
          default = {};
        };
      };
      aerc = {
        enable = mkEnableOption {
          default = elem "aerc" enabledMuas;
        };
        extraConfig = mkOption {
          type = types.attrs;
          description = "Any extra configuration for Aerc";
          default = {};
        };
      };
    };
  };

  genEnableSystemdUnit = listToAttrs (map
    (acc: {
      name = "mail-sync@${acc.name}";
      value = {
        wantedBy = [
          "mail-sync.target"
        ];
        overrideStrategy = "asDropin";
      };
    })
    cfg.accounts);
in {
  config = mkIf enabled {};
}
