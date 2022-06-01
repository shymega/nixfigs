{ config, pkgs, lib, ... }:

{

  security = { sudo.wheelNeedsPassword = false; };

  security.rtkit.enable = true;
}
