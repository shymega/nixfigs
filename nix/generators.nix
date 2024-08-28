{ self, ... }:
let
  configs = self.nixosConfigurations;
in
rec {
  MTX-SRV = configs.MTX-SRV.config.formats.proxmox-lxc;

  INSTALLER-SERVER-ISO-ARM = configs.INSTALLER-SERVER-ISO-ARM.config.formats.install-iso;
  INSTALLER-SERVER-ISO-X86 = configs.INSTALLER-SERVER-ISO-X86.config.formats.install-iso;

  INSTALLER-WORKSTATION-ISO-ARM = configs.INSTALLER-WORKSTATION-ISO-ARM.config.formats.install-iso;
  INSTALLER-WORKSTATION-ISO-X86 = configs.INSTALLER-WORKSTATION-ISO-X86.config.formats.install-iso;

  all = MTX-SRV INSTALLER-SERVER-ISO-ARM INSTALLER-SERVER-ISO-X86 INSTALLER-WORKSTATION-ISO-ARM INSTALLER-WORKSTATION-ISO-X86;
}
