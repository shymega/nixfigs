# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  hostRoles,
  ...
}: let
  inherit (lib) checkRoles;
  isWork = checkRoles ["work"] hostRoles;
  isPersonal = checkRoles ["personal"] hostRoles;
in {
  # Mutual exclusion - cannot be both work and personal
  assertions = [
    {
      assertion = !(isWork && isPersonal);
      message = "System cannot have both 'work' and 'personal' roles simultaneously";
    }
  ];

  imports =
    if isWork
    then [
      ./networking.nix
      ./applications.nix
      ./compliance.nix
      ./monitoring.nix
    ]
    else [];
}
