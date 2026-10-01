# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{pkgs, ...}: {
  environment.systemPackages = let
    inherit (pkgs.lib) getExe';
    inherit (pkgs) coreutils writeScriptBin;
    inherit (pkgs.stdenv) shell;
  in [
    (writeScriptBin "clean-syncthing" ''
      #! ${shell}
      set -eu

      ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname "*sync-conflict*" -print -delete
      ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname ".#*" -print -delete
      ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname "*~*" -print -delete
      ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname ".syncthing*" -print -delete
    '')
  ];
}
