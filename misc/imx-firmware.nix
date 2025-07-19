{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imx-firmware";
  version = "8.27-5af0ceb";

  src = fetchurl {
    url = "https://sources.buildroot.net/firmware-imx/firmware-imx-${finalAttrs.version}.bin";
    hash = "sha256-Yfkl5garAgsaNvP39+RZxoR/W528eUIfnvhuj8Ek6y8=";
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
