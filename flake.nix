{
  description = "shymega's Nix config";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-23.05"; };
    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
    nixpkgs-master = { url = "github:nixos/nixpkgs/master"; };
    nixpkgs-shymega = { url = "github:shymega/nixpkgs/master"; };

    nur = { url = "github:nix-community/NUR"; };
    flake-utils = { url = "github:numtide/flake-utils"; };

    hardware = { url = "github:nixos/nixos-hardware"; };
    impermanence = { url = "github:nix-community/impermanence"; };
    nix-colors = { url = "github:misterio77/nix-colors"; };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-ld = { url = "github:Mic92/nix-ld"; };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      overlays-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            allowUnsupportedSystem = true;
          };
          overlays = [
            (
              final: prev: {
                weechatWithMyPlugins = prev.weechat.override {
                  configure = { availablePlugins, ... }: {
                    scripts = with prev.pkgs.weechatScripts; [
                      buffer_autoset
                      colorize_nicks
                      highmon
                      url_hint
                      weechat-autosort
                      weechat-go
                      weechat-notify-send
                      zncplayback
                      wee-slack
                      weechat-matrix
                    ];
                    plugins = builtins.attrValues availablePlugins;
                  };
                };
              }
            )
            (
              final: prev: {
                mpv-unwrapped = prev.mpv-unwrapped.override {
                  ffmpeg_5 = prev.ffmpeg_5-full;
                };
              }
            )
          ];
        };
      };
      overlays-shymega = final: prev: {
        shymega = import inputs.nixpkgs-shymega {
          inherit (prev) system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            allowUnsupportedSystem = true;
          };
        };
      };
      overlays-nixpkgs-master = final: prev: {
        master = import inputs.nixpkgs-master {
          inherit (prev) system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            allowUnsupportedSystem = true;
          };
        };
      };
      nixPkgsOverlays = { config, pkgs, ... }: {
        nixpkgs.config = {
          allowUnfree = true;
          allowBroken = true;
          allowUnsupportedSystem = true;
        };
        nixpkgs.overlays = [
          overlays-unstable
          overlays-shymega
          overlays-nixpkgs-master
          inputs.nur.overlay
          inputs.nix-alien.overlays.default
        ];
      };
      mkNixos = system: extraModules: inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixPkgsOverlays
          inputs.agenix.nixosModules.default
          inputs.nix-ld.nixosModules.nix-ld
          inputs.nix-index-database.nixosModules.nix-index
          { environment.systemPackages = [ inputs.agenix.packages.${system}.default ]; }
          ./secrets
        ] ++ extraModules;
        specialArgs = { inherit inputs; };
      };
      mkHome = system: extraModules: inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};

        modules = [
          nixPkgsOverlays
          inputs.nix-index-database.hmModules.nix-index
          inputs.agenix.homeManagerModules.default
          inputs.doom-emacs.hmModule
        ] ++ extraModules;
        extraSpecialArgs = { inherit inputs; };
      };
      mkDarwin = system: extraModules: inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          nixPkgsOverlays
          inputs.agenix.darwinModules.default
          ./secrets
          { environment.systemPackages = [ inputs.agenix.defaultPackage.${system} ]; }
        ] ++ extraModules;
        specialArgs = { inherit inputs; };
      };
    in
    (inputs.flake-utils.lib.eachDefaultSystem (system:
      {
        devShells.default = import ./shell.nix {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        };
      })) // {
      nixosConfigurations = {
        ### Personal Devices ####

        ### Desktops ###

        ## Desktop (Beelink SER6 Pro) ##

        NEO-LINUX = mkNixos "x86_64-linux" [
          ./hosts/nixos/configuration.nix
          ./hosts/shared/linux
          ./hosts/nixos/NEO-LINUX
        ];

        ## End Desktop (Beelink SER6 Pro) ##

        ## Raspberry Pi - desk ##
        SMITH-LINUX = mkNixos "aarch64-linux" [
          ./hosts/nixos/configuration.nix
          ./hosts/shared/linux
          ./hosts/nixos/SMITH-LINUX
        ];
        ## End Raspberry Pi - desk ##

        ### End Desktops ###

        ### Portable Machines ###

        ## UMPC (GPD Pocket 3 (i7)) ##

        TRINITY-LINUX = mkNixos "x86_64-linux" [
          ./hosts/nixos/configuration.nix
          ./hosts/shared/linux
          ./hosts/nixos/TRINITY-LINUX
        ];

        ## End UMPC (GPD P3) ##

        # Laptop (ThinkPad X270) ##

        TWINS-LINUX = mkNixos "x86_64-linux" [
          ./hosts/nixos/configuration.nix
          ./hosts/shared/linux
          ./hosts/nixos/TWINS-LINUX
        ];

        # End Laptop (ThinkPad X270) ##

        ### End Portable Machines ###

        ### Handhelds ###

        ## Gaming Handheld (GPD Win Mini) ##
        ## TO BE ADDED. ##
        ## End Gaming Handheld (GPD Win Mini) ##

        ## Gaming Handheld (Steam Deck) ##
        ## TO BE ADDED. ##
        ## End Gaming Handheld (Steam Deck) ##

        ### End Handhelds ###

        ### Experimental Device Ports ###

        ## RISC-V Experimental Tablet (Pine64 PineTab2-V) ##
        ## TO BE ADDED. ##
        ## End RISC-v Experimental Tablet (Pine64 PineTab2-V) ##

        ## ARM64 Experimental Tablet (Pine64 PineTab2 ARM64) ##
        ## TO BE ADDED. ##
        ## End ARM64 Experimental Tablet (Pine64 PineTab2 ARM) ##

        ## ClockworkPi uConsole (CM4) ##
        ## TO BE ADDED. ##
        ## End ClockworkPi uConsole (CM4) ##

        ## ClockworkPi DevTerm (CM4) ##
        ## TO BE ADDED. ##
        ## End ClockworkPi DevTerm (CM4) ##

        ### Experimental Device Ports ###

        ### Servers ###

        ### End Servers ###

        ### Cloud Machines (VMs/Containers) ###

        ### End Cloud Machines (VMs/Containers) ###

        ### Local Machines (VMs/Containers) ###

        ### End Local Machines (VMs/Containers) ###

        ## Home Automation Nodes ##

        GRDN-BED-UNIT = mkNixos "aarch64-linux" [
          ./hosts/nixos/configuration.nix
          ./hosts/shared/linux
          ./hosts/nixos/GRDN-BED-UNIT
        ];

        ## End Home Automation Nodes ##

        ### End Personal Machines ###

        ### Work Machines ###

        ### End Work Machines ###
      };
      homeConfigurations = {
        "dzrodriguez@NEO-LINUX" = mkHome "x86_64-linux" [ ./users/home.nix ];
        "dzrodriguez@TRINITY-LINUX" = mkHome "x86_64-linux" [ ./users/home.nix ];
        "dzrodriguez@TWINS-LINUX" = mkHome "x86_64-linux" [ ./users/home.nix ];
        "dzrodriguez@SMITH-LINUX" = mkHome "aarch64-linux" [ ./users/home.nix ];
        "dzrodriguez@GRDN-BED-UNIT" = mkHome "aarch64-linux" [ ./users/home.nix ];
      };
      darwinConfigurations = {
        ### macOS (including Cloud/Local) machines ###
        ### End macOS (including Cloud/Local) machines ###
      };
    };
}
