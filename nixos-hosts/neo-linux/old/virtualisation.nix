{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = false;
  virtualisation.podman.extraPackages = [
    pkgs.skopeo
    pkgs.conmon
    pkgs.runc
    pkgs.fuse-overlayfs
    pkgs.slirp4netns
    pkgs.shadow
  ];
  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.lxd.enable = true;
}
