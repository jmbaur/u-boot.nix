{ buildArmTrustedFirmware }:
buildArmTrustedFirmware rec {
  platform = "imx8mm";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [ "build/${platform}/release/bl31.bin" ];
}
