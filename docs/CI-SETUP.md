# GitHub CI Build Setup

This document describes the GitHub CI workflow for building NixOS systems and pushing to Attic cache.

## Workflow: `build-and-cache.yml`

### Key Features

**🏗️ Build Configuration:**
- Builds all x86_64-linux and aarch64-linux systems
- Uses nixbuild.net as remote builders for efficient builds
- Filters the GitHub Actions matrix to only include these architectures

**🔐 Security & Secrets:**
- Handles sops-nix secrets with symmetric key from GitHub Secrets (`SOPS_AGE_KEY`)
- Uses nixbuild.net SSH key from GitHub Secrets (`NIXBUILD_SSH_KEY`)
- Manages Attic authentication with token (`ATTIC_TOKEN`)

**📦 Cache Management:**
- Pushes built systems to Attic cache: `private-nixfigs.attics.nix.shymega.org.uk`
- Uses the `nixfigs` cache within the Attic instance
- Includes proper authentication and trusted public keys

**🔄 Input Overrides:**
- Handles all `*-dummy` input overrides using secrets:
  - `NIXFIGS_VIRTUAL_PRIVATE_URL`
  - `NIXFIGS_WORK_URL` 
  - `NIXFIGS_PRIVATE_URL`
  - `NIXFIGS_NETWORKS_URL`
  - `SHYPKGS_PRIVATE_URL`

## Required GitHub Secrets

Configure these secrets in your repository settings:

| Secret Name | Description |
|-------------|-------------|
| `SOPS_AGE_KEY` | Your sops-nix symmetric key for decrypting secrets |
| `NIXBUILD_SSH_KEY` | SSH private key for authenticating with nixbuild.net |
| `ATTIC_TOKEN` | Authentication token for Attic cache |
| `NIXFIGS_VIRTUAL_PRIVATE_URL` | URL for nixfigs-virtual-private-dummy override |
| `NIXFIGS_WORK_URL` | URL for nixfigs-work-dummy override |
| `NIXFIGS_PRIVATE_URL` | URL for nixfigs-private-dummy override |
| `NIXFIGS_NETWORKS_URL` | URL for nixfigs-networks-dummy override |
| `SHYPKGS_PRIVATE_URL` | URL for shypkgs-private-dummy override |

## Workflow Triggers

- **Push**: Triggers on pushes to `main` and `develop` branches
- **Pull Request**: Triggers on PRs to `main` branch
- **Manual**: Can be triggered manually via workflow dispatch

## Cache Configuration

- **Attic Endpoint**: `https://private-nixfigs.attics.nix.shymega.org.uk/`
- **Cache Name**: `nixfigs`
- **Trusted Public Key**: `private-nixfigs.attics.nix.shymega.org.uk:LMl+lAu57+YHjOm6U0EYzT4VBK4YKGqGU/YZxdLLreg=`

## nixbuild.net Configuration

- **Builder Host**: `eu.nixbuild.net`
- **Supported Architectures**: `x86_64-linux`, `aarch64-linux`
- **Features**: `big-parallel`, `kvm`, `nixos-test`
- **Max Jobs**: 100 parallel builds

## Workflow Steps

1. **Matrix Generation**: Evaluates the flake to generate a build matrix for x86_64-linux and aarch64-linux systems
2. **Environment Setup**: Configures Nix, nixbuild.net SSH, sops-nix keys, and Attic authentication
3. **Build**: Builds each NixOS system configuration using remote builders
4. **Cache Push**: Pushes built systems and dependencies to Attic cache
5. **Summary**: Generates build status summary

## Troubleshooting

### Common Issues

1. **sops-nix Decryption Failures**
   - Verify `SOPS_AGE_KEY` is correctly set in GitHub Secrets
   - Ensure the key has proper permissions for the secrets being accessed

2. **nixbuild.net Connection Issues**
   - Verify `NIXBUILD_SSH_KEY` is a valid SSH private key
   - Check nixbuild.net account status and quotas

3. **Attic Push Failures**
   - Verify `ATTIC_TOKEN` has push permissions for the `nixfigs` cache
   - Check Attic server connectivity and status

4. **Dummy Input Override Failures**
   - Ensure all `*_URL` secrets point to valid, accessible repositories
   - Verify the repositories contain the expected flake structure

### Debugging

- Check the workflow logs for detailed error messages
- Use the build summary section for quick status overview
- Verify all required secrets are properly configured in repository settings

## Security Considerations

- All secrets are handled securely through GitHub Secrets
- SSH keys and tokens are never exposed in logs
- sops-nix keys are stored in temporary locations with restricted permissions
- Network authentication is handled through secure channels

## Performance Optimizations

- Uses nixbuild.net for distributed building across multiple architectures
- Implements disk space cleanup to prevent runner storage issues
- Uses Magic Nix Cache for improved build performance
- Leverages Attic cache for dependency sharing between builds