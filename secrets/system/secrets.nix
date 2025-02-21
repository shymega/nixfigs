# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

let
  NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8Stawqd09idKurIZ+eSSEbmWdXIlQQJ4eaMo6bmClv";
  NEO-WSL = "";
  NEO-JOVIAN = "";
  TWINS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAp9kcBykTqbYroj9akZ7s6qY7NsX9uHwZMv64dOKvV";
  MORPHEUS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMXwoQwm7t9/KXJG5L4gk+Q5DGccetgbxYfhtsbBbgS";
  MORPHEUS-JOVIAN = "";
  MORPHEUS-WSL = "";

  DELTA-ZERO = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU";
  DIAL-IN = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd2G/XmmLSK4V+tBgkS62/qE4fsY8c0dYKyjkiYtqpX";

  personal-machines = [
    NEO-LINUX
    NEO-WSL
    NEO-JOVIAN
    TWINS-LINUX
    MORPHEUS-LINUX
    MORPHEUS-JOVIAN
    MORPHEUS-WSL
  ];

  rnet-machines = [
    DELTA-ZERO
    DIAL-IN
  ];
in
{
  "postfix_sasl_passwd.age".publicKeys = personal-machines;
  "postfix_sender_relay.age".publicKeys = personal-machines;
  "dzrodriguez.age".publicKeys = personal-machines ++ rnet-machines;
  "geoclue_url.age".publicKeys = personal-machines;
  "zerotier_networks.age".publicKeys = personal-machines ++ rnet-machines;
  "wireless.age".publicKeys = personal-machines;
  "synapse_secret.age".publicKeys = [ DELTA-ZERO ];
  "cloudflare_dns_token.age".publicKeys = [ DELTA-ZERO ];
  "nixbuild_ssh_priv_key.age".publicKeys = personal-machines;
  "nixbuild_ssh_pub_key.age".publicKeys = personal-machines;
  "matrix-sliding-sync-env.age".publicKeys = rnet-machines;
  "nix_conf_access_tokens.age".publicKeys = personal-machines;
  "restic/env.age".publicKeys = personal-machines;
  "restic/repo.age".publicKeys = personal-machines;
  "restic/pw.age".publicKeys = personal-machines;
}
