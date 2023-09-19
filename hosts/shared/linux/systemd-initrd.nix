{ config, lib, ... }:
{ boot.initrd.systemd.enable = lib.mkForce true; }
