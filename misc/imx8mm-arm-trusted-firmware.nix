{ buildArmTrustedFirmware }:
buildArmTrustedFirmware rec {
  platform = "imx8mm";
  extraMeta.platforms = [ "aarch64-linux" ];
  extraMakeFlags = [ "IMX_BOOT_UART_BASE=auto" ];
  filesToInstall = [ "build/${platform}/release/bl31.bin" ];
}
