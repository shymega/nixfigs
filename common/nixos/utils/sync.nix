{ pkgs, ... }:
{
  tidy-syncthing = pkgs.writeScriptBin "clean-syncthing" ''
    #! ${pkgs.stdenv.shell}
    set -eu

    ${pkgs.coreutils.outPath}/bin/find /home/dzr/{Documents,Multimedia,projects} -type f -iname "*sync-conflict*" -print -delete
    ${pkgs.coreutils.outPath}/bin/find /home/dzr/{Documents,Multimedia,projects} -type f -iname ".#*" -print -delete
    ${pkgs.coreutils.outPath}/bin/find /home/dzr/{Documents,Multimedia,projects} -type f -iname "*~*" -print -delete
    ${pkgs.coreutils.outPath}/bin/find /home/dzr/{Documents,Multimedia,projects} -type f -iname ".syncthing*" -print -delete
  '';

  

}
