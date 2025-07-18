# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./aspell.nix
    ./common_env.nix
    ./containers.nix
    ./fish.nix
    ./fonts.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./tmux.nix
  ];

  documentation = {
    enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  environment = {
    pathsToLink = [
      "/share/fish"
      "/share/zsh"
    ];
    systemPackages = with pkgs; [
      neovim
      rsync
    ];
  };

  programs = {
    nix-index.enable = false;
    fish.enable = true;
    zsh.enable = true;
    command-not-found.enable = lib.mkForce false;
  };
}
