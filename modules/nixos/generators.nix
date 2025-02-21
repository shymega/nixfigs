{ inputs, system, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
  ];

  nixpkgs.hostPlatform = system;
}
