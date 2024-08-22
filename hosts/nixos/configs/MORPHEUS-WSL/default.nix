# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, lib, ... }:
{
  imports =
    [ inputs.nixos-wsl.nixosModules.default ]
    ++ lib.optionals (lib.versionOlder lib.version "24.11pre") [
      (lib.mkAliasOptionModule
        [
          "hardware"
          "graphics"
          "extraPackages32"
        ]
        [
          "hardware"
          "opengl"
          "extraPackages32"
        ]
      )
      (lib.mkAliasOptionModule
        [
          "hardware"
          "graphics"
          "enable32Bit"
        ]
        [
          "hardware"
          "opengl"
          "driSupport32Bit"
        ]
      )
      (lib.mkAliasOptionModule
        [
          "hardware"
          "graphics"
          "package"
        ]
        [
          "hardware"
          "opengl"
          "package"
        ]
      )
      (lib.mkAliasOptionModule
        [
          "hardware"
          "graphics"
          "package32"
        ]
        [
          "hardware"
          "opengl"
          "package32"
        ]
      )
    ];

  networking.hostName = "MORPHEUS-WSL";
  wsl.wslConf.network.generateResolvConf = lib.mkForce false;

  services = {
    ollama = {
      enable = false;
      acceleration = "rocm";
      sandbox = false;
      models = "/data/AI/LLMs/Ollama/Models/";
      writablePaths = [ "/data/AI/LLMs/Ollama/Models/" ];
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M
      };
    };
  };

  wsl = {
    enable = true;
    defaultUser = "dzrodriguez";
  };

  system.stateVersion = "24.05";

}
