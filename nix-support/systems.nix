# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

# Centralized system definitions to reduce duplication
{
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}:
{
  # All supported systems
  allSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  # Linux-specific systems
  linuxSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];

  # Darwin-specific systems
  darwinSystems = [
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  # Default systems for most operations
  defaultSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  # Systems supported by treefmt
  treefmtSystems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  # Systems supported by devshells
  devshellSystems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # Systems supported by checks
  checkSystems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # Helper function to generate attrs for each system
  forEachSystem = systems: f: lib.genAttrs systems f;

  # Helper function for all systems
  forAllSystems =
    f:
    lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
      "riscv64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] f;

  # Helper function for default systems
  forDefaultSystems =
    f:
    lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ] f;

  # Helper function for development systems
  forDevSystems =
    f:
    lib.genAttrs [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ] f;

  # Check if system is supported
  isSystemSupported =
    system:
    lib.elem system [
      "x86_64-linux"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
      "riscv64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

  # Check if system is Linux
  isLinux = system: lib.hasSuffix "-linux" system;

  # Check if system is Darwin
  isDarwin = system: lib.hasSuffix "-darwin" system;

  # Get platform for GitHub Actions
  systemToPlatform =
    system:
    let
      inherit (lib.strings) hasSuffix;
      isDarwin = system: hasSuffix "-darwin" system;
    in
    if system == "aarch64-linux" then
      "ubuntu-24.04-arm"
    else if hasSuffix "-linux" system then
      "ubuntu-24.04"
    else if isDarwin system then
      "macos-14"
    else
      throw "Unsupported system (platform): ${system}";
}
