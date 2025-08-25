final: prev:

let
  inherit (final)
    armTrustedFirmwareAllwinnerH616
    armTrustedFirmwareImx8mm
    armTrustedFirmwareImx8mp
    armTrustedFirmwareRK3588
    imxFirmware
    makeUBoot
    opensbi
    rkbin
    ;
in
builtins.listToAttrs (
  map
    (args: {
      name = "uboot-${args.boardName}";
      value = makeUBoot args;
    })
    [
      # qemu
      {
        boardName = "qemu_arm";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "qemu_arm64";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "qemu-riscv32";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "riscv32-linux" ];
      }
      {
        boardName = "qemu-riscv32_smode";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "riscv32-linux" ];
      }
      {
        boardName = "qemu-riscv64";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "riscv64-linux" ];
      }
      {
        boardName = "qemu-riscv64_smode";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "riscv64-linux" ];
      }
      {
        boardName = "qemu-x86";
        artifacts = [ "u-boot.rom" ];
        meta.platforms = [ "x86_64-linux" ];
      }

      # other
      {
        boardName = "socfpga_de10_nano";
        artifacts = [ "spl/u-boot-spl.sfp" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "clearfog";
        artifacts = [ "u-boot-with-spl.kwb" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "clearfog_sata";
        artifacts = [ "u-boot-with-spl.kwb" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "clearfog_spi";
        artifacts = [ "u-boot-with-spl.kwb" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "bananapi_m2_zero";
        artifacts = [ "u-boot-sunxi-with-spl.bin" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "bananapi_m2_plus_h3";
        artifacts = [ "u-boot-sunxi-with-spl.bin" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "rpi_0_w";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "armv7l-linux" ];
      }
      {
        boardName = "orangepi-5-rk3588s";
        artifacts = [
          "u-boot-rockchip.bin"
          "u-boot-rockchip-spi.bin"
        ];
        makeFlags = [
          "BL31=${armTrustedFirmwareRK3588}/bl31.elf"
          "ROCKCHIP_TPL=${rkbin.TPL_RK3588}"
        ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "orangepi_zero2w";
        artifacts = [ "u-boot-sunxi-with-spl.bin" ];
        # TODO(jared): this board actually has an H618, can we still use the same
        # TF-A build?
        makeFlags = [ "BL31=${armTrustedFirmwareAllwinnerH616}/bl31.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "orangepi_zero3";
        artifacts = [ "u-boot-sunxi-with-spl.bin" ];
        # TODO(jared): this board actually has an H618, can we still use the same
        # TF-A build?
        makeFlags = [ "BL31=${armTrustedFirmwareAllwinnerH616}/bl31.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "mt7986a_bpir3_sd";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "mt7986a_bpir3_emmc";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "mvebu_mcbin-88f8040";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "rpi_4";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "rpi_arm64";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "mt8183_pumpkin";
        artifacts = [ "u-boot-mtk.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "p2771-0000-000";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "p2771-0000-500";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "imx8mp_evk";
        artifacts = [ "flash.bin" ];
        preConfigure = ''
          install -m0644 --target-directory=$(pwd) ${imxFirmware}/*
        '';
        makeFlags = [ "BL31=${armTrustedFirmwareImx8mp}/bl31.bin" ];
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "phycore-imx8mm";
        artifacts = [ "flash.bin" ];
        makeFlags = [ "BL31=${armTrustedFirmwareImx8mm}/bl31.bin" ];
        preConfigure = ''
          install -m0644 --target-directory=$(pwd) ${imxFirmware}/*
        '';
        meta.platforms = [ "aarch64-linux" ];
      }
      {
        boardName = "starfive_visionfive2";
        artifacts = [
          "u-boot.bin"
          "spl/u-boot-spl.bin"
        ];
        makeFlags = [
          "OPENSBI=${
            opensbi.overrideAttrs (old: {
              makeFlags = (old.makeFlags or [ ]) ++ [
                "FW_TEXT_START=0x40000000"
                "FW_OPTIONS=0"
              ];
            })
          }/share/opensbi/lp64/generic/firmware/fw_dynamic.elf"
        ];
        meta.platforms = [ "riscv64-linux" ];
      }
      {
        boardName = "coreboot";
        artifacts = [ "u-boot.bin" ];
        meta.platforms = [ "x86_64-linux" ];
      }
      {
        boardName = "coreboot64";
        artifacts = [ "u-boot-x86-with-spl.bin" ];
        meta.platforms = [ "x86_64-linux" ];
      }
    ]
)
