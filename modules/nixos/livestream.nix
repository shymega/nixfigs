{ lib
, config
, pkgs
, ...
}:
with lib;
let
  rtmpOverlay = final: prev: {
    nginxStable = prev.nginxStable.override (oldAttrs: {
      modules = oldAttrs.modules ++ [ prev.nginxModules.rtmp ];
    });
  };
  cfg = config.nixfigs.services.livestream;
in
{
  options.nixfigs.services.livestream = {
    enable = mkEnableOption "Livestreaming Nginx server";

    settings = {
      youtube = {
        enable = mkEnableOption "Enable Youtube streaming";
        key = mkOption {
          type = with lib.types; str;
          description = "Youtube API key";
        };
      };
      peertube = {
        enable = mkEnableOption "Enable Peertube streaming";
        key = mkOption {
          type = with lib.types; str;
          description = "Peertube API key";
        };
        instanceUrl = mkOption {
          type = with lib.types; str;
          description = "Peertube instance URL";
        };
      };
      twitch = {
        enable = mkEnableOption "Enable Twitch streaming";
        key = mkOption {
          type = with lib.types; str;
          description = "Twitch API key";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ rtmpOverlay ];
    services.nginx = {
      enable = true;
      appendConfig = ''
        rtmp {
          server {
            listen 2036;
            chunk_size 4096;
            application live {
              live on;
              record off;
              ${if cfg.settings.youtube.enable then
                "push rtmp://a.rtmp.youtube.com/live2/${cfg.settings.youtube.key}"
              else
                ""
              }
              ${if cfg.settings.peertube.enable then
                "push rtmp://${cfg.settings.peertube.instanceUrl}/live/${cfg.settings.peertube.key}"
              else
                ""
              }
              ${if cfg.settings.twitch.enable then
                "push rtmp://live.twitch.tv/app/${cfg.settings.twitch.key}"
              else
                ""
              }
            }
          }
        }
      '';
    };
  };
}
