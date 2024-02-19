{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "rkbin";
  version = builtins.substring 0 7 finalAttrs.src.rev;

  src = fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "b4558da0860ca48bf1a571dd33ccba580b9abe23";
    hash = "sha256-KUZQaQ+IZ0OynawlYGW99QGAOmOrGt2CZidI3NTxFw8=";
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    find bin -type f \
      -exec install -D --target-directory=$out {} \;
  '';

  meta.license = lib.licenses.unfree;
})
