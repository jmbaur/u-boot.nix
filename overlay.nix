final: prev: {
  rockchipFirmware = prev.callPackage ./misc/rockchip-firmware.nix { };
  imxFirmware = prev.callPackage ./misc/imx-firmware.nix { };
  armTrustedFirmwareImx8mm = prev.callPackage ./misc/imx8mm-arm-trusted-firmware.nix { };
} // (import ./boards.nix { pkgs = final; })
