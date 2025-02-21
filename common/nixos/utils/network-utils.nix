{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeScriptBin "net-type" ''
      #! ${pkgs.stdenv.shell}
      set -eu

      exec ${pkgs.networkmanager.outPath}/bin/nmcli \
        networking connectivity
    '')
  ];
}
