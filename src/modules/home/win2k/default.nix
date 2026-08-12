# Layers the hypr-dotw2k Windows 2000 (Luna) theme on top of this flake's
# own Home-Manager modules. hypr-dotw2k is a generic, portable module that
# uses `lib.mkForce` on every option it touches, so it wins over whatever
# nixfigs-hypr's own waybar/swaync/hyprland modules already set —
# regardless of import order.
#
# Not handled by hypr-dotw2k (by design — it can't assume this flake's
# Lua-based Hyprland bind DSL): binding a key to launch rofi. Add your own,
# e.g. in homeModules/hypr/hyprland/default.nix's `settings.bind` list:
#   (bind "SUPER + R" (dsp.exec "rofi -show drun"))
{
  config,
  inputs,
  lib,
  ...
}: {
  imports = lib.optionals config.nixfigs.win2k.enable [
    inputs.hypr-dotw2k.homeManagerModules.default
  ];

  config = lib.mkIf config.nixfigs.win2k.enable {
    programs.hypr-dotw2k.enable = true;
  };
}
