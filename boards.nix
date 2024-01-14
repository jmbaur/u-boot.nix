{ pkgs, pkgsForBoard ? _: pkgs }:

let
  inherit (pkgs) lib;

  ubootLib = import ./lib.nix { inherit lib; };

  mkBoard = arch: name: artifacts: boardArgs: {
    inherit name;
    value = { inherit arch artifacts boardArgs; };
  };

  mkAarch64Board = mkBoard "aarch64-linux";
  mkArmv7Board = mkBoard "armv7l-linux";
  mkX86_64Board = mkBoard "x86_64-linux";
  mkRiscv32Board = mkBoard "riscv32-linux";
  mkRiscv64Board = mkBoard "riscv64-linux";

  rkBin = pkgs.fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "b4558da0860ca48bf1a571dd33ccba580b9abe23";
    hash = "sha256-KUZQaQ+IZ0OynawlYGW99QGAOmOrGt2CZidI3NTxFw8=";
  };
in
builtins.listToAttrs (map
  ({ name, value }:
  let
    boardPkgs = pkgsForBoard value.arch;
    boardArgs =
      if lib.isFunction value.boardArgs then
        value.boardArgs boardPkgs
      else
        value.boardArgs;
  in
  lib.nameValuePair
    "uboot-${name}"
    (boardPkgs.callPackage ./u-boot.nix ({
      boardName = name;
      inherit ubootLib;
      inherit (value) artifacts arch;
    } // boardArgs))
  ) [
  # qemu
  (mkArmv7Board "qemu_arm" [ "u-boot.bin" ] { })
  (mkAarch64Board "qemu_arm64" [ "u-boot.bin" ] { })
  (mkRiscv32Board "qemu-riscv32" [ "u-boot.bin" ] { })
  (mkRiscv32Board "qemu-riscv32_smode" [ "u-boot.bin" ] { })
  (mkRiscv64Board "qemu-riscv64" [ "u-boot.bin" ] { })
  (mkRiscv64Board "qemu-riscv64_smode" [ "u-boot.bin" ] { })
  (mkX86_64Board "qemu-x86" [ "u-boot.rom" ] { })
  (mkX86_64Board "qemu-x86_64" [ "u-boot.rom" ] { })

  # other
  (mkArmv7Board "clearfog" [ "u-boot-with-spl.kwb" ] { })
  (mkArmv7Board "clearfog_sata" [ "u-boot-with-spl.kwb" ] { })
  (mkArmv7Board "clearfog_spi" [ "u-boot-with-spl.kwb" ] { })
  (mkArmv7Board "bananapi_m2_zero" [ "u-boot-sunxi-with-spl.bin" ] { })
  (mkArmv7Board "bananapi_m2_plus_h3" [ "u-boot-sunxi-with-spl.bin" ] { })
  (mkArmv7Board "rpi_0_w" [ "u-boot.bin" ] { })
  (mkAarch64Board "orangepi-5-rk3588s" [ "u-boot-rockchip.bin" ] {
    extraMakeFlags = [
      "BL31=${rkBin}/bin/rk35/rk3588_bl31_v1.40.elf"
      "ROCKCHIP_TPL=${rkBin}/bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.12.bin"
    ];
  })
  (mkAarch64Board "orangepi_zero3" [ "u-boot-sunxi-with-spl.bin" ] (pkgs: {
    # TODO(jared): this board actually has an H618, can we still use the same
    # TF-A build?
    extraMakeFlags = [ "BL31=${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin" ];
  }))
  (mkAarch64Board "mt7986a_bpir3_sd" [ "u-boot.bin" ] { })
  (mkAarch64Board "mt7986a_bpir3_emmc" [ "u-boot.bin" ] { })
  (mkAarch64Board "mvebu_mcbin-88f8040" [ "u-boot.bin" ] { })
  (mkAarch64Board "rpi_4" [ "u-boot.bin" ] { })
  (mkAarch64Board "mt8183_pumpkin" [ "u-boot-mtk.bin" ] { })
  (mkX86_64Board "coreboot" [ "u-boot.bin" ] { })
  (mkX86_64Board "coreboot64" [ "u-boot-x86-with-spl.bin" ] { })
])
