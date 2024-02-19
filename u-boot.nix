initialArgs:
{ bc
, bison
, fetchFromGitHub
, flex
, gnutls
, lib
, libuuid
, ncurses
, openssl
, pkgsBuildBuild
, python3Packages
, stdenv
, swig
, ubootLib
, which
, xxd
  # TODO(jared): document these options
, boardName
, artifacts ? [ ]
, arch
, extraMakeFlags ? [ ]
, extraStructuredConfig ? { }
, configfile ? null
}:

let
  extraConfig = ubootLib._internal.serialize extraStructuredConfig;
in
stdenv.mkDerivation (finalAttrs: (initialArgs // {
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
    gnutls
    libuuid
    ncurses
    openssl
    swig
    which
    xxd
  ] ++ (with python3Packages; [
    libfdt
    pyelftools
    setuptools
  ]);

  buildInputs = [ ];

  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "DTC=${lib.getExe' pkgsBuildBuild.dtc "dtc"}"
  ] ++ extraMakeFlags;


  inherit extraConfig;
  passAsFile = [ "extraConfig" ];

  configurePhase = ''
    runHook preConfigure
  '' + (if configfile != null then ''
    install -Dm0644 ${configfile} .config
  '' else ''
    bash ${./merge_config.bash} \
      configs/${boardName}_defconfig $extraConfigPath >.config
  '') + ''
    make olddefconfig
    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall
  '' + (lib.concatMapStrings
    (file: ''
      install -D --target-directory=$out ${file}
    '')
    (artifacts ++ [ ".config" ])) + ''
    runHook postInstall
  '';

  meta.platforms = [ arch ];
}))

