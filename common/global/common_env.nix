{ config, lib, pkgs, ... }: {
  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "emacsclient -c";
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
      SUDO_EDITOR = "$EDITOR";
    };
    systemPackages = with pkgs; [
      git
      killall
      nano
      pciutils
      usbutils
      wget
      gnupg
      pinentry-curses
      pinentry-rofi
      htop
      xorg.xinit
      bc
      acpi
      tmux
      nix-index
    ];
  };
}
