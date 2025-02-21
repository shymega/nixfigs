{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    acpi
    curl
    encfs
    fido2luks
    fuse
    git
    gnupg
    htop
    iw
    lm_sensors
    nano
    nix-alien
    nvme-cli
    pciutils
    powertop
    protonvpn-cli
    protonvpn-gui
    smartmontools
    solo2-cli
    tmux
    usbutils
    wget
  ];
  programs = {
    nix-ld.enable = true;
    command-not-found.enable = false;
    bash.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
  };
}
