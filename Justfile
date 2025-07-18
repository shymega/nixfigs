# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

# NixOS Flake Justfile
# Common commands for this NixOS configuration flake

# Default recipe - show available commands
default:
    @just --list

# Variables for dummy input overrides (set these in your environment)
NIXFIGS_VIRTUAL_PRIVATE_URL := env_var_or_default('NIXFIGS_VIRTUAL_PRIVATE_URL', 'github:shymega/nixfigs-virtual-private')
NIXFIGS_WORK_URL := env_var_or_default('NIXFIGS_WORK_URL', 'github:shymega/nixfigs-work')
NIXFIGS_PRIVATE_URL := env_var_or_default('NIXFIGS_PRIVATE_URL', 'github:shymega/nixfigs-private')
NIXFIGS_NETWORKS_URL := env_var_or_default('NIXFIGS_NETWORKS_URL', 'github:shymega/nixfigs-networks')
SHYPKGS_PRIVATE_URL := env_var_or_default('SHYPKGS_PRIVATE_URL', 'github:shymega/shypkgs-private')

# Override arguments for dummy inputs
override_args := "--override-input nixfigs-virtual-private " + NIXFIGS_VIRTUAL_PRIVATE_URL + " --override-input nixfigs-work " + NIXFIGS_WORK_URL + " --override-input nixfigs-private " + NIXFIGS_PRIVATE_URL + " --override-input nixfigs-networks " + NIXFIGS_NETWORKS_URL + " --override-input shypkgs-private " + SHYPKGS_PRIVATE_URL

# === FLAKE OPERATIONS ===

# Check flake and run all checks
check:
    nix flake check --all-systems --accept-flake-config {{override_args}}

# Update flake inputs
update:
    nix flake update {{override_args}}

# Show flake info
info:
    nix flake show {{override_args}}

# Show flake metadata
metadata:
    nix flake metadata {{override_args}}

# === FORMATTING ===

# Format code using treefmt
fmt:
    nix fmt {{override_args}}

# Check formatting without applying changes
fmt-check:
    nix run '.#formatter' {{override_args}} -- --check --diff

# === DEVELOPMENT ===

# Enter development shell
dev:
    nix develop {{override_args}}

# Run pre-commit checks
pre-commit:
    nix run '.#checks.x86_64-linux.pre-commit-check' {{override_args}}

# === SYSTEM BUILDS ===

# Build a specific NixOS configuration
build host:
    nix build {{override_args}} --accept-flake-config --show-trace '.#nixosConfigurations.{{host}}.config.system.build.toplevel'

# Build work laptop specifically
build-work:
    nix build {{override_args}} --accept-flake-config --show-trace '.#nixosConfigurations.ct-lt-2671.config.system.build.toplevel'

# Build all systems (warning: resource intensive)
build-all:
    nix run {{override_args}} '.#builds'

# Build specific system for specific architecture
build-arch host arch:
    nix build {{override_args}} --accept-flake-config --show-trace --system {{arch}} '.#nixosConfigurations.{{host}}.config.system.build.toplevel'

# === HOME MANAGER ===

# Build home-manager configuration
build-home user:
    nix build {{override_args}} --accept-flake-config '.#homeConfigurations.{{user}}.activationPackage'

# === DEPLOYMENT ===

# Deploy using deploy-rs
deploy host:
    nix run {{override_args}} 'github:serokell/deploy-rs' -- --hostname {{host}} '.#{{host}}'

# Deploy with skip health checks
deploy-force host:
    nix run {{override_args}} 'github:serokell/deploy-rs' -- --hostname {{host}} --skip-checks '.#{{host}}'

# Check deployment configuration
deploy-check:
    nix run {{override_args}} 'github:serokell/deploy-rs' -- --dry-activate

# === VM TESTING ===

# Build and run VM for testing
vm host:
    nix build {{override_args}} --accept-flake-config '.#nixosConfigurations.{{host}}.config.system.build.vm'
    ./result/bin/run-{{host}}-vm

# === SYSTEM ACTIVATION ===

# Switch to new configuration (requires sudo)
switch host:
    sudo nixos-rebuild switch --flake '.#{{host}}' {{override_args}}

# Test configuration without switching boot
test host:
    sudo nixos-rebuild test --flake '.#{{host}}' {{override_args}}

# Build configuration and set as boot default
boot host:
    sudo nixos-rebuild boot --flake '.#{{host}}' {{override_args}}

# Work laptop specific commands
switch-work:
    sudo nixos-rebuild switch --flake '.#ct-lt-2671' {{override_args}}

test-work:
    sudo nixos-rebuild test --flake '.#ct-lt-2671' {{override_args}}

boot-work:
    sudo nixos-rebuild boot --flake '.#ct-lt-2671' {{override_args}}

# === GARBAGE COLLECTION ===

# Clean up old generations and garbage collect
gc:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Delete old generations (specify number of days)
gc-old days="7":
    sudo nix-collect-garbage --delete-older-than {{days}}d
    nix-collect-garbage --delete-older-than {{days}}d

# === UTILITY ===

# Show system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Show available hosts
hosts:
    nix eval --json {{override_args}} '.#nixosConfigurations' --apply 'builtins.attrNames' | jq -r '.[]'

# Show work hosts only
hosts-work:
    @echo "ct-lt-2671 (work laptop)"

# Show personal hosts only  
hosts-personal:
    @echo "Available personal hosts:"
    @nix eval --json {{override_args}} '.#nixosConfigurations' --apply 'lib.filterAttrs (n: v: builtins.elem "personal" v.config.nixfigs.meta.rolesEnabled) >> builtins.attrNames' 2>/dev/null | jq -r '.[]' || echo "DEUSEX-LINUX\nNEO-LINUX"

# Show available home configurations
homes:
    nix eval --json {{override_args}} '.#homeConfigurations' --apply 'builtins.attrNames' | jq -r '.[]'

# Show available packages
packages:
    nix eval --json {{override_args}} '.#packages.x86_64-linux' --apply 'builtins.attrNames' | jq -r '.[]'

# === GITHUB ACTIONS TESTING ===

# Generate GitHub Actions matrix locally
gh-matrix:
    nix eval --json {{override_args}} '.#githubActions'

# Build systems from GitHub Actions matrix
gh-build:
    #!/usr/bin/env bash
    set -euo pipefail
    matrix=$(nix eval --json {{override_args}} '.#githubActions')
    echo "$matrix" | jq -r '.include[] | select(.system == "x86_64-linux" or .system == "aarch64-linux") | "\(.hostName)@\(.system)"' | while read -r host_system; do
        host=$(echo "$host_system" | cut -d'@' -f1)
        system=$(echo "$host_system" | cut -d'@' -f2)
        echo "Building $host for $system..."
        nix build {{override_args}} --accept-flake-config --system "$system" ".#nixosConfigurations.$host.config.system.build.toplevel"
    done

# === CACHE OPERATIONS ===

# Push built systems to binary cache (requires attic setup)
cache-push host:
    nix run nixpkgs#attic-client -- push nixfigs $(nix path-info {{override_args}} --accept-flake-config --derivation '.#nixosConfigurations.{{host}}.config.system.build.toplevel')

# === SECRETS MANAGEMENT ===

# Edit secrets with sops
secrets-edit file:
    sops {{file}}

# Edit work secrets
edit-work-secrets file:
    SOPS_AGE_KEY_FILE=~/.config/sops/work/keys.txt sops secrets/work/hosts/ct-lt-2671/{{file}}.yaml

# Edit personal secrets  
edit-personal-secrets host file:
    SOPS_AGE_KEY_FILE=~/.config/sops/personal/keys.txt sops secrets/personal/hosts/{{host}}/{{file}}.yaml

# Rotate age keys
secrets-rotate:
    find secrets -name "*.yaml" -exec sops rotate -i {} \;

# Rotate work secrets only
rotate-work-secrets:
    find secrets/work -name "*.yaml" -exec env SOPS_AGE_KEY_FILE=~/.config/sops/work/keys.txt sops rotate -i {} \;

# Rotate personal secrets only
rotate-personal-secrets:
    find secrets/personal -name "*.yaml" -exec env SOPS_AGE_KEY_FILE=~/.config/sops/personal/keys.txt sops rotate -i {} \;

# Validate all secrets can be decrypted
validate-secrets:
    @echo "Validating work secrets..."
    @find secrets/work -name "*.yaml" -exec env SOPS_AGE_KEY_FILE=~/.config/sops/work/keys.txt sops -d {} > /dev/null \; 2>/dev/null || echo "⚠️  Work secrets validation failed (keys may not be set up)"
    @echo "Validating personal secrets..."
    @find secrets/personal -name "*.yaml" -exec env SOPS_AGE_KEY_FILE=~/.config/sops/personal/keys.txt sops -d {} > /dev/null \; 2>/dev/null || echo "⚠️  Personal secrets validation failed (keys may not be set up)"

# === GIT-CRYPT MANAGEMENT ===

# Check git-crypt status
git-crypt-status:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt status; \
    else \
        echo "git-crypt not installed. Install with: nix-shell -p git-crypt"; \
    fi

# Lock git-crypt (encrypt work files)
git-crypt-lock:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt lock; \
        echo "Work files encrypted. Use 'just git-crypt-unlock' to decrypt."; \
    else \
        echo "git-crypt not installed"; \
    fi

# Unlock git-crypt (decrypt work files)
git-crypt-unlock:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt unlock; \
        echo "Work files decrypted and ready for editing."; \
    else \
        echo "git-crypt not installed"; \
    fi

# Unlock with symmetric key file
git-crypt-unlock-key keyfile:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt unlock {{keyfile}}; \
        echo "Work files decrypted using key file."; \
    else \
        echo "git-crypt not installed"; \
    fi

# Add GPG user to git-crypt
git-crypt-add-user fingerprint:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt add-gpg-user {{fingerprint}}; \
        echo "Added GPG user {{fingerprint}} to git-crypt"; \
        echo "Commit the changes with: git add .git-crypt/keys/ && git commit"; \
    else \
        echo "git-crypt not installed"; \
    fi

# Export git-crypt symmetric key for backup
git-crypt-export-key:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt export-key git-crypt-backup-key.bin; \
        echo "Symmetric key exported to git-crypt-backup-key.bin"; \
        echo "Store this file securely - it can decrypt all work files!"; \
    else \
        echo "git-crypt not installed"; \
    fi

# Initialize git-crypt (first time setup)
git-crypt-init:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt init; \
        echo "Git-crypt initialized. Add GPG users with: just git-crypt-add-user FINGERPRINT"; \
    else \
        echo "git-crypt not installed"; \
    fi

# Check which files are encrypted
git-crypt-list-encrypted:
    @if command -v git-crypt >/dev/null 2>&1; then \
        git-crypt status -e; \
    else \
        echo "git-crypt not installed"; \
    fi

# Validate work files can be built (requires unlocked git-crypt)
validate-work-build:
    @echo "Checking if git-crypt is unlocked..."
    @if command -v git-crypt >/dev/null 2>&1; then \
        if git-crypt status >/dev/null 2>&1; then \
            echo "✅ Git-crypt unlocked, attempting work build..."; \
            just build-work; \
        else \
            echo "❌ Git-crypt locked. Run 'just git-crypt-unlock' first."; \
            exit 1; \
        fi; \
    else \
        echo "⚠️  Git-crypt not available, building without encryption..."; \
        just build-work; \
    fi

# === DOCUMENTATION ===

# Generate system documentation
docs:
    nix build {{override_args}} '.#nixosConfigurations' --apply 'lib.mapAttrs (name: cfg: cfg.config.system.build.manual.manualHTML)' || echo "Manual generation not available for all systems"

# Show system options for a host
options host:
    nix eval --json {{override_args}} '.#nixosConfigurations.{{host}}.options' --apply 'builtins.attrNames' | jq -r '.[]' | head -20
