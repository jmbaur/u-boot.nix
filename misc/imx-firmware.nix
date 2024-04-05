{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imx-firmware";
  version = "8.20";

  src = fetchurl {
    url = "http://sources.buildroot.net/firmware-imx/firmware-imx-${finalAttrs.version}.bin";
    hash = "sha256-9txqXI/ZuROhU2DTzNU9GI2wWgioWUxRjldiJHjHI4M=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    bash $src --auto-accept --force
    find firmware-imx-${finalAttrs.version}/firmware -type f \
      -exec install -D --target-directory=$out {} \;
  '';

  meta.license = lib.licenses.unfree;
})
