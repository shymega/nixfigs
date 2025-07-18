# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

# Git-Crypt Setup Guide

This repository uses git-crypt to encrypt work-specific configurations, providing an additional layer of security on top of SOPS-NIX.

## Overview

- **Work modules**: `src/modules/nixos/work/**` - Encrypted
- **Work systems**: `src/systems/ct-lt-2671@x86_64-linux/**` - Encrypted  
- **Work secrets**: `secrets/work/**` - Double-encrypted (SOPS + git-crypt)
- **Work host configs**: `hosts/declarations/conf.d/ct-lt-2671.nix` - Encrypted

## Initial Setup

### 1. Install git-crypt

```bash
# NixOS/Nix
nix-shell -p git-crypt

# Ubuntu/Debian
sudo apt install git-crypt

# macOS
brew install git-crypt
```

### 2. Initialize git-crypt (First Time)

```bash
# Initialize git-crypt in the repository
git-crypt init

# Generate or use existing GPG key for work
gpg --gen-key  # If you don't have a work GPG key

# Add your GPG key to git-crypt
git-crypt add-gpg-user YOUR_GPG_FINGERPRINT

# Export symmetric key for backup (store securely!)
git-crypt export-key git-crypt-key.bin
```

### 3. Clone/Setup (Subsequent Users)

```bash
# Clone the repository
git clone <repo-url>
cd nixfigs

# Either unlock with GPG key
git-crypt unlock

# Or unlock with symmetric key
git-crypt unlock /path/to/git-crypt-key.bin
```

## Key Management

### Adding New GPG Keys

```bash
# Add a new user's GPG key
git-crypt add-gpg-user NEW_USER_GPG_FINGERPRINT

# Commit the changes
git add .git-crypt/keys/
git commit -m "Add new GPG key for work configs access"
```

### Backup and Recovery

```bash
# Export symmetric key for backup
git-crypt export-key backup-key.bin

# Store this key securely (password manager, encrypted storage)
# This key can decrypt all files if GPG keys are lost

# Recovery from symmetric key
git-crypt unlock backup-key.bin
```

## File Encryption Patterns

### Automatically Encrypted (via .gitattributes)

- `src/modules/nixos/work/**` - All work modules
- `src/systems/ct-lt-2671@x86_64-linux/**` - Work laptop system
- `secrets/work/**` - Work secrets (double-encrypted)
- `hosts/declarations/conf.d/ct-lt-2671.nix` - Work host declaration

### Always Readable (Excluded)

- `flake.nix`, `flake.lock` - Core Nix files
- `README.md` - Documentation
- `.github/**` - CI/CD configurations
- `Justfile` - Build commands

## Usage Commands

### Check Encryption Status

```bash
# See which files are encrypted
git-crypt status

# See which files would be encrypted (dry run)
git-crypt status -e
```

### Lock/Unlock

```bash
# Lock repository (encrypt files)
git-crypt lock

# Unlock repository (decrypt files)
git-crypt unlock

# Unlock with specific key
git-crypt unlock /path/to/key.bin
```

### Key Management

```bash
# List GPG users who can decrypt
git-crypt status -r

# Add new GPG user
git-crypt add-gpg-user GPG_FINGERPRINT

# Export symmetric key
git-crypt export-key key.bin
```

## Justfile Integration

Common git-crypt operations are available via Justfile:

```bash
# Check git-crypt status
just git-crypt-status

# Lock encrypted files
just git-crypt-lock

# Unlock encrypted files  
just git-crypt-unlock

# Add new GPG user
just git-crypt-add-user GPG_FINGERPRINT

# Export backup key
just git-crypt-export-key
```

## Security Considerations

### Double Encryption

Work secrets use both SOPS-NIX and git-crypt:
1. **SOPS-NIX**: Application-level encryption with age/GPG
2. **Git-crypt**: Repository-level encryption

This provides defense in depth - even if one encryption layer is compromised, work data remains protected.

### Key Separation

- **Personal configs**: Only SOPS-NIX encryption
- **Work configs**: Both SOPS-NIX and git-crypt encryption
- **VM configs**: Only SOPS-NIX encryption (personal use)

### Access Control

- Git-crypt keys should be work-specific GPG keys
- Symmetric keys should be stored in corporate key management
- Regular key rotation following corporate policy

## Troubleshooting

### Files Not Encrypting

```bash
# Check .gitattributes patterns
cat .gitattributes | grep git-crypt

# Force re-encryption of files
git add --renormalize .
```

### Cannot Decrypt

```bash
# Check if repository is unlocked
git-crypt status

# Verify GPG key is available
gpg --list-secret-keys

# Try unlocking with symmetric key
git-crypt unlock /path/to/backup-key.bin
```

### Merge Conflicts with Encrypted Files

```bash
# Unlock before merging
git-crypt unlock

# Resolve conflicts normally
git merge ...

# Files will be re-encrypted on commit
```

## Integration with Development Workflow

### Pre-commit Hooks

Ensure git-crypt is unlocked before builds:

```bash
#!/bin/sh
# Check if git-crypt is unlocked
if ! git-crypt status >/dev/null 2>&1; then
    echo "Error: git-crypt locked. Run 'git-crypt unlock' first."
    exit 1
fi
```

### CI/CD Considerations

- CI systems should use symmetric keys for git-crypt
- Store symmetric key in CI secrets manager
- Unlock repository before build steps

### Local Development

```bash
# Always unlock before working on work configs
git-crypt unlock

# Build work system
just build-work

# Commit changes (files auto-encrypt)
git add .
git commit -m "Update work configuration"
```