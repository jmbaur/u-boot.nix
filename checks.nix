{ pkgs }:
let
  pkgsForBoard =
    arch:
    if arch == pkgs.stdenv.buildPlatform.system then
      pkgs
    else
      {
        "x86_64-linux" = pkgs.pkgsCross.gnu64;
        "aarch64-linux" = pkgs.pkgsCross.aarch64-multiplatform;
        "armv7l-linux" = pkgs.pkgsCross.armv7l-hf-multiplatform;
        "riscv32-linux" = pkgs.pkgsCross.riscv32;
        "riscv64-linux" = pkgs.pkgsCross.riscv64;
      }
      .${arch};
in
import ./boards.nix { inherit pkgs pkgsForBoard; }
