# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

let
  dzrodriguez-NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1L44C2mZnuRysLRq98P+ri7pkpl0dyTzr/3EAQ7Qov dzrodriguez@NEO-LINUX";
  users = [ dzrodriguez-NEO-LINUX ];

  NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8Stawqd09idKurIZ+eSSEbmWdXIlQQJ4eaMo6bmClv";
  TRINITY-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7DcpK52k1LV7EIuPTw47irtNFn2TfoQVtd860tVpvp";
  DELTA-ZERO = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU root@DELTA-ZERO";

  personal = [ NEO-LINUX TRINITY-LINUX ];
  work = [ ];
  rnet-servers = [ DELTA-ZERO ];

  systems = personal ++ work ++ rnet-servers;

  allKeys = users ++ systems;
in
{
  "postfix_sasl_passwd.age".publicKeys = allKeys;
  "postfix_sender_relay.age".publicKeys = allKeys;
  "user_dzrodriguez.age".publicKeys = allKeys;
}
