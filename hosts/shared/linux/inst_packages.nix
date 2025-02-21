{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
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
  ] ++ [ pkgs.nix-alien ];
  programs = {
    nix-ld.enable = true;
    command-not-found.enable = false;
    bash.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
  };
}
