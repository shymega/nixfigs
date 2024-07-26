# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, ... }:
{
  networking.hostName = "MORPHEUS-WSL";

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
}
