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
, python3Packages
, boardName
, artifacts ? [ ]
, extraMakeFlags ? [ ]
, arch
, extraStructuredConfig ? { }
}:

stdenv.mkDerivation (finalAttrs:
let
  defaultConfig = lib.mapAttrs (_: lib.mkDefault)
    (ubootLib.deserialize
      (builtins.readFile "${finalAttrs.src}/configs/${boardName}_defconfig"));

  evaluatedConfig = (lib.evalModules {
    modules = [
      { freeformType = lib.types.anything; }
      defaultConfig
      extraStructuredConfig
    ];
  }).config;

  dotconfig = ubootLib.serialize evaluatedConfig;

  filesToInstall = artifacts ++ [ ".config" ];
in
{
  pname = "uboot-${boardName}";
  version = "2024.01-rc4";

  src = fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7qNOEvCzJe4wsV0NWQsa59nvO7bfgKqmm++faNHviBY=";
  };

  postPatch = ''
    patchShebangs tools scripts
  '';

  enableParallelBuilding = true;

  depsBuildBuild = [ pkgsBuildBuild.stdenv.cc ];

  nativeBuildInputs = [ bison flex swig openssl ncurses bc ] ++
    (with python3Packages; [ libfdt pyelftools setuptools ]);

  buildInputs = [ ];

  makeFlags = [ "CROSS_COMPILE=${stdenv.cc.targetPrefix}" ] ++ extraMakeFlags;

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
})
