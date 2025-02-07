# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixos-wsl.nixosModules.default];

  networking.hostName = "MORPHEUS-WSL";
  wsl.wslConf.network.generateResolvConf = lib.mkForce false;

  services = {
    ollama = {
      enable = false;
      acceleration = "rocm";
      models = "/data/AI/LLMs/Ollama/Models/";
      writablePaths = ["/data/AI/LLMs/Ollama/Models/"];
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M
      };
    };
  };

  wsl = {
    enable = true;
    defaultUser = "dzrodriguez";
  };

  system.stateVersion = "24.11";
}
