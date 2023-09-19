{ inputs, outputs, pkgs, lib, config, ... }: {
  nix = {
    optimise.automatic = true;
    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      substituters = [ "https://cache.dataaturservice.se/spectrum/" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "spectrum-os.org-1:rnnSumz3+Dbs5uewPlwZSTP0k3g/5SRG4hD7Wbr9YuQ="
      ];
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = true;
      system-features = [ "kvm" "big-parallel" ];
    };
    daemonCPUSchedPolicy = "batch";
    extraOptions = ''
      gc-keep-outputs = false
      gc-keep-derivations = false
    '';
    package = pkgs.nixVersions.unstable;
    registry.nixpkgs.flake = inputs.nixpkgs;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };
}
