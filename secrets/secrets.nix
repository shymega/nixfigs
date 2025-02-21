# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

let
  dzrodriguez-NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7D0z5Unwjt00URZxRrx6T69PFc6xI3zHETtr0GbkM6 dzrodriguez@NEO-LINUX";
  dzrodriguez-TRINITY-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMof07iqwcqoSuHoL0UAfKMeM6g6B5bL2klAmOLCJtNJ dzrodriguez@TRINITY-LINUX";
  personal-users = [ dzrodriguez-NEO-LINUX dzrodriguez-TRINITY-LINUX ];

  NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8Stawqd09idKurIZ+eSSEbmWdXIlQQJ4eaMo6bmClv";
  TRINITY-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9Iwy4iP4/lpSsLGKqrnMwO0AUvOHqgBc/RimkLrnQh";
  TWINS-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAp9kcBykTqbYroj9akZ7s6qY7NsX9uHwZMv64dOKvV";
  DELTA-ZERO = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU";
  DIAL-IN = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd2G/XmmLSK4V+tBgkS62/qE4fsY8c0dYKyjkiYtqpX";

  personal-machines = [ NEO-LINUX TRINITY-LINUX TWINS-LINUX ];
  personal = personal-users ++ personal-machines;

  work-machines = [ ];
  work-users = [ ];

  rnet-machines = [ DELTA-ZERO DIAL-IN ];
  rnet-users = [ ];
  rnet = rnet-users ++ rnet-machines;

  servers = rnet-machines;

  all-machines = personal-machines ++ work-machines ++ rnet-machines;
  all-users = personal-users ++ work-users ++ rnet-users;

  allKeys = all-machines ++ all-users;
in
{
  "postfix_sasl_passwd.age".publicKeys = personal;
  "postfix_sender_relay.age".publicKeys = personal;
  "user_dzrodriguez.age".publicKeys = allKeys;
  "atuin_key.age".publicKeys = allKeys;
  "geoclue_url.age".publicKeys = personal;
}
