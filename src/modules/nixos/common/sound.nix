# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: {
  services.actkbd = let
    volumeStep = "1%";
  in {
    enable = true;
    bindings = [
      # "Mute" media key
      {
        keys = [113];
        events = ["key"];
        command = "${alsa-utils}/bin/amixer -q set Master toggle";
      }

      # "Lower Volume" media key
      {
        keys = [114];
        events = [
          "key"
          "rep"
        ];
        command = "${alsa-utils}/bin/amixer -q set Master ${volumeStep}- unmute";
      }

      # "Raise Volume" media key
      {
        keys = [115];
        events = [
          "key"
          "rep"
        ];
        command = "${alsa-utils}/bin/amixer -q set Master ${volumeStep}+ unmute";
      }

      # "Mic Mute" media key
      {
        keys = [190];
        events = ["key"];
        command = "${alsa-utils}/bin/amixer -q set Capture toggle";
      }
    ];
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    audio.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = false;
  };
}
