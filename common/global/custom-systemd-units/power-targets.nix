{
  systemd.targets.ac = {
    conflicts = [ "battery.target" ];
    description = "On AC power";
    unitConfig = {
      RefuseManualStart = "true";
      DefaultDependencies = "false";
    };
  };

  systemd.targets.battery = {
    conflicts = [ "ac.target" ];
    description = "On battery power";
    unitConfig = {
      RefuseManualStart = "true";
      DefaultDependencies = "false";
    };
  };
}
