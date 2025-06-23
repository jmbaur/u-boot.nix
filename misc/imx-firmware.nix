{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imx-firmware";
  version = "8.22";

  src = fetchurl {
    url = "http://sources.buildroot.net/firmware-imx/firmware-imx-${finalAttrs.version}.bin";
    hash = "sha256-lMi86sVuxQPCMuYU931rvY4Xx9qnHU5lHqj9UDTDA1A=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    bash $src --auto-accept --force
    find firmware-imx-${finalAttrs.version}/firmware -type f \
      -exec install -D --target-directory=$out {} \;
    runHook postInstall
  '';

  meta.license = lib.licenses.unfree;
})
