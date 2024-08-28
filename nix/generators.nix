{ self, ... }:
let
  configs = self.nixosConfigurations;
in
{
  MTX-SRV = configs.MTX-SRV.config.formats.proxmox-lxc;
  INSTALLER-SERVER-ISO = configs.INSTALLER-SERVER-ISO.config.formats.install-iso;
}
