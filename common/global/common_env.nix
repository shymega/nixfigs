{ inputs, config, lib, pkgs, ... }:
let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    config = {
      allowUnfree = true;
      system = "x86_64-linux";
    };
  };
in {
  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "emacsclient -c";
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
      SUDO_EDITOR = "$EDITOR";
    };
    systemPackages = with nixpkgs-unstable; [
      acpi
      bc
      git
      gnupg
      htop
      killall
      nano
      pciutils
      powertop
      tmux
      usbutils
      wget
      xorg.xinit
      protonvpn-cli
    ];
  };
}
