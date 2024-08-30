# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

let
  dzrodriguez-NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7D0z5Unwjt00URZxRrx6T69PFc6xI3zHETtr0GbkM6";
  dzrodriguez-TWINS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOZyVmZ3OdKl2f1kLSEnwwKaO8ecDKEbwLYXDAllIvU ";
  dzrodriguez-MORPHEUS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgAqM0gz24k8J1vqe3cp1MI48cSok6mtdMIYnT1d8CR";
  nixos-MORPHEUS-WSL = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbxdHlDVWPqpUTifSdvO3wMVg43u2coy+akmIYkaQ9W";
  personal-users = [
    dzrodriguez-NEO-LINUX
    dzrodriguez-TWINS-LINUX
    dzrodriguez-MORPHEUS-LINUX
    nixos-MORPHEUS-WSL
  ];

  rnet-users = [ ];
in
{
  "atuin_key.age".publicKeys = personal-users ++ rnet-users;
  "nix_conf_access_tokens.age".publicKeys = personal-users ++ rnet-users;
}
