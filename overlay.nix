final: prev:
let
  ubootLib = import ./lib.nix { inherit (prev) lib; };
in
{
  ubootLib = ubootLib._external;
  rockchipFirmware = prev.callPackage ./misc/rockchip-firmware.nix { };
  imxFirmware = prev.callPackage ./misc/imx-firmware.nix { };
  armTrustedFirmwareImx8mm = prev.callPackage ./misc/imx8mm-arm-trusted-firmware.nix {};
} // (import ./boards.nix { pkgs = final; lib = prev.lib; })
