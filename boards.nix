{
  pkgs,
  pkgsForBoard ? _: pkgs,
}:

let
  mkBoard = arch: name: artifacts: initialBoardArgs: boardArgs: {
    inherit name;
    value = {
      inherit
        arch
        artifacts
        initialBoardArgs
        boardArgs
        ;
    };
  };

  mkAarch64Board = mkBoard "aarch64-linux";
  mkArmv7Board = mkBoard "armv7l-linux";
  mkX86_64Board = mkBoard "x86_64-linux";
  mkRiscv32Board = mkBoard "riscv32-linux";
  mkRiscv64Board = mkBoard "riscv64-linux";
in
builtins.listToAttrs (
  map
    (
      { name, value }:
      let
        boardPkgs = pkgsForBoard value.arch;
        initialBoardArgs =
          if builtins.isFunction value.initialBoardArgs then
            value.initialBoardArgs boardPkgs
          else
            value.initialBoardArgs;
        boardArgs =
          if builtins.isFunction value.boardArgs then value.boardArgs boardPkgs else value.boardArgs;
      in
      {
        name = "uboot-${name}";
        value = boardPkgs.callPackage (import ./u-boot.nix initialBoardArgs) (
          {
            boardName = name;
            inherit (value) artifacts arch;
          }
          // boardArgs
        );
      }
    )
    [
      # qemu
      (mkArmv7Board "qemu_arm" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "qemu_arm64" [ "u-boot.bin" ] { } { })
      (mkRiscv32Board "qemu-riscv32" [ "u-boot.bin" ] { } { })
      (mkRiscv32Board "qemu-riscv32_smode" [ "u-boot.bin" ] { } { })
      (mkRiscv64Board "qemu-riscv64" [ "u-boot.bin" ] { } { })
      (mkRiscv64Board "qemu-riscv64_smode" [ "u-boot.bin" ] { } { })
      (mkX86_64Board "qemu-x86" [ "u-boot.rom" ] { } { })
      (mkX86_64Board "qemu-x86_64" [ "u-boot.rom" ] { } { })

      # other
      (mkArmv7Board "clearfog" [ "u-boot-with-spl.kwb" ] { } { })
      (mkArmv7Board "clearfog_sata" [ "u-boot-with-spl.kwb" ] { } { })
      (mkArmv7Board "clearfog_spi" [ "u-boot-with-spl.kwb" ] { } { })
      (mkArmv7Board "bananapi_m2_zero" [ "u-boot-sunxi-with-spl.bin" ] { } { })
      (mkArmv7Board "bananapi_m2_plus_h3" [ "u-boot-sunxi-with-spl.bin" ] { } { })
      (mkArmv7Board "rpi_0_w" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "orangepi-5-rk3588s" [ "u-boot-rockchip.bin" ] { } (pkgs: {
        extraMakeFlags = [
          "BL31=${pkgs.armTrustedFirmwareRK3588}/bl31.elf"
          "ROCKCHIP_TPL=${pkgs.rkbin.TPL_RK3588}"
        ];
      }))
      (mkAarch64Board "orangepi_zero2w" [ "u-boot-sunxi-with-spl.bin" ] { } (pkgs: {
        # TODO(jared): this board actually has an H618, can we still use the same
        # TF-A build?
        extraMakeFlags = [ "BL31=${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin" ];
      }))
      (mkAarch64Board "orangepi_zero3" [ "u-boot-sunxi-with-spl.bin" ] { } (pkgs: {
        # TODO(jared): this board actually has an H618, can we still use the same
        # TF-A build?
        extraMakeFlags = [ "BL31=${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin" ];
      }))
      (mkAarch64Board "mt7986a_bpir3_sd" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "mt7986a_bpir3_emmc" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "mvebu_mcbin-88f8040" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "rpi_4" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "mt8183_pumpkin" [ "u-boot-mtk.bin" ] { } { })
      (mkAarch64Board "p2771-0000-000" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "p2771-0000-500" [ "u-boot.bin" ] { } { })
      (mkAarch64Board "phycore-imx8mm"
        [
          "u-boot.itb"
          "spl/u-boot-spl.bin"
          "flash.bin"
        ]
        (pkgs: {
          preConfigure = ''
            install -m0644 --target-directory=$(pwd) ${pkgs.imxFirmware}/*
          '';
        })
        (pkgs: {
          extraMakeFlags = [
            "BL31=${pkgs.armTrustedFirmwareImx8mm}/bl31.bin"
            "flash.bin"
          ];
        })
      )
      (mkRiscv64Board "starfive_visionfive2" [ ] { } (pkgs: {
        extraMakeFlags = [
          "OPENSBI=${
            pkgs.opensbi.overrideAttrs (old: {
              makeFlags = old.makeFlags ++ [
                "FW_TEXT_START=0x40000000"
                "FW_OPTIONS=0"
              ];
            })
          }/share/opensbi/lp64/generic/firmware/fw_dynamic.elf"
        ];
      }))
      (mkX86_64Board "coreboot" [ "u-boot.bin" ] { } { })
      (mkX86_64Board "coreboot64" [ "u-boot-x86-with-spl.bin" ] { } { })
    ]
)
