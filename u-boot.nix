{ lib
, ubootLib
, stdenv
, fetchFromGitHub
, pkgsBuildBuild
, bison
, flex
, swig
, openssl
, ncurses
, bc
, vim
, which
, python3Packages
, debug ? false
, boardName
, artifacts ? [ ]
, extraMakeFlags ? [ ]
, arch
, extraStructuredConfig ? { }
}:

stdenv.mkDerivation (finalAttrs:
let
  defaultConfig = lib.mapAttrs (_: lib.mkDefault)
    (ubootLib._internal.deserialize
      (builtins.readFile "${finalAttrs.src}/configs/${boardName}_defconfig"));

  evaluatedConfig = (lib.evalModules {
    modules = [
      { freeformType = lib.types.anything; }
      defaultConfig
      extraStructuredConfig
    ];
  }).config;

  dotconfig = ubootLib._internal._serialize { configAttrs = evaluatedConfig; inherit debug; };

  filesToInstall = artifacts ++ [ ".config" ];
in
{
  pname = "uboot-${boardName}";
  version = "2024.01";

  src = fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0Da7Czy9cpQ+D5EICc3/QSZhAdCBsmeMvBgykYhAQFw=";
  };

  postPatch = ''
    patchShebangs tools scripts
  '';

  enableParallelBuilding = true;

  depsBuildBuild = [ pkgsBuildBuild.stdenv.cc ];

  nativeBuildInputs = [
    bc
    bison
    flex
    ncurses
    openssl
    swig
    vim # xxd
    which
  ] ++
  (with python3Packages; [ libfdt pyelftools setuptools ]);

  buildInputs = [ ];

  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "DTC=${lib.getExe' pkgsBuildBuild.dtc "dtc"}"
  ] ++ extraMakeFlags;

  inherit dotconfig;
  passAsFile = [ "dotconfig" ];
  configurePhase = ''
    runHook preConfigure
    cat $dotconfigPath >.config
    make olddefconfig
    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall
  '' + (lib.concatLines
    (map
      (file: "install -D --target-directory=$out ${file}")
      filesToInstall)) + ''
    runHook postInstall
  '';

  meta.platforms = [ arch ];

  passthru.config = evaluatedConfig;
})
