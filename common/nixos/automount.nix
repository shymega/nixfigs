{ pkgs
, ...
}:
{
  system.activationScripts.rp2040-mountpoint = ''
    ${pkgs.coreutils}/bin/mkdir -pv /mnt/dev/rp2040
  '';

  services.udev.extraRules = ''
    # RP2040 Pico
     ACTION=="add|change" \
    , SUBSYSTEMS=="usb" \
    , SUBSYSTEM=="block" \
    , ENV{ID_FS_USAGE}=="filesystem" \
    , ENV{ID_FS_LABEL}=="RPI-RP2" \
    , RUN{program}+="${pkgs.systemd}/bin/systemd-mount --owner=1001 --no-block --collect $devnode /mnt/dev/rp2040"


    # USB storage devices:
      ACTION=="add|change" \
    , SUBSYSTEM=="block" \
    , ENV{ID_FS_USAGE}=="filesystem" \
    , ENV{ID_FS_LABEL}!="RPI-RP2" \
    , RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --owner=1001 --collect $devnode /run/media/system/$env{ID_FS_UUID}"

    ACTION=="remove" \
    , SUBSYSTEM=="block" \
    , ENV{ID_FS_USAGE}=="filesystem" \
    , ENV{ID_FS_LABEL}!="RPI-RP2" \
    , RUN{program}+="${pkgs.systemd}/bin/systemd-mount --umount /run/media/system/$env{ID_FS_UUID}"
  '';
}
