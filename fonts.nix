# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  fonts.fonts = with pkgs; [
    open-dyslexic
    fira
    fira-code
    jetbrains-mono
    font-awesome_5
    font-awesome_4
    noto-fonts
    noto-fonts-emoji
    emojione
    twemoji-color-font
  ];
}
