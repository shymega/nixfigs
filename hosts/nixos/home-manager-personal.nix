{ config
, self
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
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."dzrodriguez" = import ../../homes;
    extraSpecialArgs = {
      inherit
        hostAddress
        hostType
        pkgs
        config
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
