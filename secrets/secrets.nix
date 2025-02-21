# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

let
  dzrodriguez-NEO = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1L44C2mZnuRysLRq98P+ri7pkpl0dyTzr/3EAQ7Qov dzrodriguez@NEO-LINUX";
  users = [ dzrodriguez-NEO ];

  NEO-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8Stawqd09idKurIZ+eSSEbmWdXIlQQJ4eaMo6bmClv";
  TRINITY-LINUX = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7DcpK52k1LV7EIuPTw47irtNFn2TfoQVtd860tVpvp";
  systems = [ NEO-LINUX TRINITY-LINUX ];

  allKeys = users ++ systems;
in
{
  "postfix_sasl_passwd.age".publicKeys = allKeys;
  "postfix_sender_relay.age".publicKeys = allKeys;
  "user_dzrodriguez.age".publicKeys = allKeys;
  "taskwarrior_sync_cert.age".publicKeys = allKeys;
  "taskwarrior_sync_key.age".publicKeys = allKeys;
  "taskwarrior_sync_ca.age".publicKeys = allKeys;
  "taskwarrior_sync_cred.age".publicKeys = allKeys;
}
