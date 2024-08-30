{ self
, hostAddress
, hostType
, pkgs
, system
, inputs
, lib
, username
, embedHm
, hostRole
, specialArgs
, deployable
, hostname
, hostPlatform
, ...
}:
inputs.home-manager.nixosModules.home-manager
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."dzrodriguez" = import ../../homes;
    extraSpecialArgs = {
      inherit
        hostAddress
        hostType
        pkgs
        system
        self
        inputs
        lib
        username
        embedHm
        hostRole
        specialArgs
        deployable
        hostname
        hostPlatform;
    };
  };
}
