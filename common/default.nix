# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs
, lib
, pkgs
, hostType
, hostname
, ...
}:
{
  imports =
    [ (import ./core { inherit inputs lib pkgs hostname; }) ]
    ++ (
      if hostType == "nixos" then
        [
          (import ./nixos {
            inherit
              inputs
              lib
              pkgs
              hostname
              ;
          })
        ]
      else if hostType == "darwin" then
        [
          (import ./darwin {
            inherit
              inputs
              lib
              pkgs
              hostname
              ;
          })
        ]
      else
        [ ]
    );
}
