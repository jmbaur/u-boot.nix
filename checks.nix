{ pkgs }:

let
  inherit (pkgs.lib)
    filterAttrs
    hasPrefix
    mapAttrs
    findFirst
    ;
  inherit (pkgs.lib.meta) availableOn;
in
mapAttrs (
  name: value:
  (findFirst (pkgs: availableOn pkgs.stdenv.hostPlatform value)
    (throw "failed to find compatible package-set for ${name}")
    [
      pkgs
      pkgs.pkgsCross.aarch64-multiplatform
      pkgs.pkgsCross.armv7l-hf-multiplatform
      pkgs.pkgsCross.gnu64
      pkgs.pkgsCross.riscv32
      pkgs.pkgsCross.riscv64
    ]
  ).${name}
) (filterAttrs (name: _: hasPrefix "uboot-" name) pkgs)
