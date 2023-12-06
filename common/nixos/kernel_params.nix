{ config, lib, ... }:
{
  boot.kernelParams = lib.mkAfter [
    "loglevel=3"
    "quiet"
    "rd.udev.log_level=3"
    "splash"
    "systemd.show_status=auto"
    "systemd.unified_cgroup_hierarchy=1"
  ];
}
