{
channels,
namespace ? null,
inputs,
... }:
final: prev: let
  nixpkgs = inputs.nixpkgs.legacyPackages.${prev.system};
in {
  qemu = nixpkgs.qemu.overrideAttrs (oldAttrs: {
    version = "fuckupieceofshit";
    buildInputs = [ nixpkgs.zlib ] ++ oldAttrs.buildInputs;
    nativeBuildInputs = [ nixpkgs.zlib ] ++ oldAttrs.nativeBuildInputs;
  });
}
