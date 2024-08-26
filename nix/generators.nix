{ self, ... }:
let
  configs = self.nixosConfigurations;
in
{
  x86_64-linux = {
    MTX-SRV = configs.MTX-SRV.config.formats.proxmox-lxc;
  };
}
