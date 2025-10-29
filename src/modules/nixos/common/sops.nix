# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkSopsConfig;
in
  # Use the unified secrets discovery system
  mkSopsConfig {
    inherit config;
    secretsInput = inputs.nixfigs-secrets;
  }
