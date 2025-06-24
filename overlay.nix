final: prev:
{
  imxFirmware = prev.callPackage ./misc/imx-firmware.nix { };
  armTrustedFirmwareImx8mm = prev.callPackage ./misc/imx8mm-arm-trusted-firmware.nix { };
  armTrustedFirmwareImx8mp = prev.callPackage ./misc/imx8mp-arm-trusted-firmware.nix { };
}
// (import ./boards.nix { pkgs = final; })
