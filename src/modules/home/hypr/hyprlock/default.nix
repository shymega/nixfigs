{
  config,
  lib,
  ...
}: let
  cfg = config.nixfigs.hypr.hyprlock;
in {
  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };

        animations = {
          enabled = true;
          fade_in = {
            duration = 300;
            bezier = "easeOutQuint";
          };
          fade_out = {
            duration = 300;
            bezier = "easeOutQuint";
          };
        };
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 64;
            font_family = "sans-serif";
            color = "rgb(202, 211, 245)";
            position = "0, 160";
            halign = "center";
            valign = "center";
            shadow_passes = 2;
          }
          {
            monitor = "";
            text = "cmd[update:3600000] date +'%A, %d %B'";
            font_size = 20;
            font_family = "sans-serif";
            color = "rgb(202, 211, 245)";
            position = "0, 90";
            halign = "center";
            valign = "center";
            shadow_passes = 2;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "<span foreground=\"##cad3f5\">Password...</span>";
            shadow_passes = 2;
          }
        ];
      };
    };
  };
}
