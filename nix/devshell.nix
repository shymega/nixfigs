{ pkgs, ... }:
with pkgs; {
  default = mkShell {
    name = "nix-config";

    nativeBuildInputs = [
      # Nix
      agenix
      deploy-rs.deploy-rs
      nil
      nix-melt
      nix-output-monitor
      nix-tree
      nixpkgs-fmt
      cachix
      nix-eval-jobs
      statix

      # Shell
      shellcheck
      shfmt

      # GitHub Actions
      act
      actionlint
      python3Packages.pyflakes
      shellcheck

      # Misc
      jq
      pre-commit
      rage
    ];
  };
}
