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

  NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8Stawqd09idKurIZ+eSSEbmWdXIlQQJ4eaMo6bmClv";
  TWINS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAp9kcBykTqbYroj9akZ7s6qY7NsX9uHwZMv64dOKvV";
  MORPHEUS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqOAfNq3lGPElJ0L6qAqQLDykRWsN9dE4sMZkD6YVKu";
  MORPHEUS-WSL = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEw1gq7SDBBKkEBN9k4YyekfMVC68TiPmZH38gCae0+T";

  DELTA-ZERO = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU";
  DIAL-IN = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd2G/XmmLSK4V+tBgkS62/qE4fsY8c0dYKyjkiYtqpX";

  personal-machines = [
    NEO-LINUX
    TWINS-LINUX
    MORPHEUS-LINUX
    MORPHEUS-WSL
  ];
  personal = personal-users ++ personal-machines;

  rnet-machines = [
    DELTA-ZERO
    DIAL-IN
  ];
  rnet-users = [ ];
  rnet = rnet-machines ++ rnet-users;
in
{
  "atuin_key.age".publicKeys = personal ++ rnet;
  "nix_conf_access_tokens.age".publicKeys = personal ++ rnet;
}
