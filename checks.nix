{ pkgs }:
let
  boards = import ./boards.nix { inherit pkgs; };

  ubootLib = import ./lib.nix { inherit (pkgs) lib; };
in
builtins.listToAttrs (map
  ({ name, value }:
  let
    pkgsForBoard =
      if value.arch == pkgs.stdenv.buildPlatform.system then
        pkgs
      else
        {
          "x86_64-linux" = pkgs.pkgsCross.gnu64;
          "aarch64-linux" = pkgs.pkgsCross.aarch64-multiplatform;
          "armv7l-linux" = pkgs.pkgsCross.armv7l-hf-multiplatform;
          "riscv32-linux" = pkgs.pkgsCross.riscv32;
          "riscv64-linux" = pkgs.pkgsCross.riscv64;
        }.${value.arch};
  in
  pkgs.lib.nameValuePair
    "uboot-${name}"
    (pkgsForBoard.callPackage ./u-boot.nix {
      boardName = name;
      inherit ubootLib;
      inherit (value) artifacts extraMakeFlags arch;
    })
  )
  boards)
