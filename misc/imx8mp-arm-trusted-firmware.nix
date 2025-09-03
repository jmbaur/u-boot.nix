{ buildArmTrustedFirmware }:
buildArmTrustedFirmware (finalAttrs: {
  platform = "imx8mp";
  meta.platforms = [ "aarch64-linux" ];
  makeFlags = [ "IMX_BOOT_UART_BASE=auto" ];
  filesToInstall = [ "build/${finalAttrs.platform}/release/bl31.bin" ];
})
