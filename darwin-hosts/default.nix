{ lib, inputs, nixpkgs, home-manager, nix-darwin, ...}:
{
  mac-vm = darwin.lib.darwinSystem {
    system = "x86_64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
        ./mac-vm/configuration.nix
      
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.dzrodriguez = import ../users/home.nix
      }
    ];
  };
}
