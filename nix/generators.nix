{ self, ... }:
let
  configs = self.nixosConfigurations;
in
rec {
  MATRIX-LXC = configs.MATRIX-LXC.config.formats.proxmox-lxc;

  BUILDER-AGENT-LXC = configs.BUILDER-AGENT-LXC.config.formats.docker;
  BUILDER-HYDRA-LXC = configs.BUILDER-HYDRA-LXC.config.formats.docker;

  INSTALLER-SERVER-ISO-ARM = configs.INSTALLER-SERVER-ISO-ARM.config.formats.install-iso;
  INSTALLER-SERVER-ISO-X86 = configs.INSTALLER-SERVER-ISO-X86.config.formats.install-iso;

  INSTALLER-WORKSTATION-ISO-ARM = configs.INSTALLER-WORKSTATION-ISO-ARM.config.formats.install-iso;
  INSTALLER-WORKSTATION-ISO-X86 = configs.INSTALLER-WORKSTATION-ISO-X86.config.formats.install-iso;

  all = MATRIX-LXC // INSTALLER-SERVER-ISO-ARM // INSTALLER-SERVER-ISO-X86 // INSTALLER-WORKSTATION-ISO-ARM // INSTALLER-WORKSTATION-ISO-X86 // BUILDER-AGENT-LXC // BUILDER-HYDRA-LXC;
}
