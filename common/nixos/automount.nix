_:
{
  fileSystems = {
    "/mnt/pi/pico" = {
      device = "/dev/disk/by-label/RPI-RP2";
      fsType = "vfat";
      options = [
        "nofail"
        "uid=1001"
        "gid=100"
        "nofail"
        "x-systemd.automount"
      ];
    };
  };
}
