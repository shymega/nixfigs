{ inputs, config, lib, pkgs, ... }:
let
  nixpkgs-unstable =
    import inputs.nixpkgs-unstable { config = { allowUnfree = true; }; };
in {
  programs.nix-ld.enable = true;

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
      nixpkgs-unstable.gnupg
      htop
      xorg.xinit
      bc
      acpi
      tmux
      nix-alien
      nix-index-update
      nix-index
    ];
  };
}
