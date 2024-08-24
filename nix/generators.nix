{ self, ... }:
let
  configs = self.nixosConfigurations;
in
{
  MTX-SRV = configs.MTX-SRV.config.formats.proxmox-lxc;
}
