# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [
    (
      let
        inherit (pkgs) coreutils;
        inherit (lib) getExe';
      in
      pkgs.writeShellScriptBin "clean-syncthing" ''
        ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname "*sync-conflict*" -print -delete
        ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname ".#*" -print -delete
        ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname "*~*" -print -delete
        ${getExe' coreutils "find"} /home/dzr/{Documents,Multimedia,projects} -type f -iname ".syncthing*" -print -delete
      ''
    )
  ];
}
