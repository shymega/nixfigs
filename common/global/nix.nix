{ pkgs, inputs, lib, config, ... }: {
  nix = {
    optimise.automatic = true;
    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = true;
      system-features = [ "kvm" "big-parallel" ];
    };
    package = pkgs.nixVersions.unstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    daemonCPUSchedPolicy = "batch";
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };
}
