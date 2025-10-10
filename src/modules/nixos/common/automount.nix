# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{pkgs, ...}: {
  system.activationScripts.rp2040-mountpoint = ''
    ${pkgs.lib.getExe' pkgs.coreutils "mkdir"} -pv /mnt/dev/rp2040
  '';

  services.udev.extraRules = ''
    # RP2040 Pico
     ACTION=="add|change" \
    , SUBSYSTEMS=="usb" \
    , SUBSYSTEM=="block" \
    , ENV{ID_FS_USAGE}=="filesystem" \
    , ENV{ID_FS_LABEL}=="RPI-RP2" \
    , RUN{program}+="${pkgs.lib.getExe' pkgs.systemd "systemd-mount"} --owner=1000 --no-block --collect $devnode /mnt/dev/rp2040"


    # USB storage devices:
      ACTION=="add|change" \
    , SUBSYSTEM=="block" \
    , ENV{ID_FS_USAGE}=="filesystem" \
    , ENV{ID_FS_LABEL}!="RPI-RP2" \
    , RUN{program}+="${pkgs.lib.getExe' pkgs.systemd "systemd-mount"} --no-block --automount=yes --owner=1000 --collect $devnode /run/media/system/$env{ID_FS_UUID}"

    ACTION=="remove" \
    , SUBSYSTEM=="block" \
    , ENV{ID_FS_USAGE}=="filesystem" \
    , ENV{ID_FS_LABEL}!="RPI-RP2" \
    , RUN{program}+="${pkgs.lib.getExe' pkgs.systemd "systemd-mount"} --umount /run/media/system/$env{ID_FS_UUID}"
  '';
}
