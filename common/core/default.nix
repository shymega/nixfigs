# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ pkgs, lib, ... }:
{
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
    enable = lib.mkForce true;
    doc.enable = lib.mkForce true;
    man.enable = lib.mkForce true;
    info.enable = lib.mkForce true;
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
    nix-index.enable = true;
    fish.enable = true;
    zsh.enable = true;
  };
}
