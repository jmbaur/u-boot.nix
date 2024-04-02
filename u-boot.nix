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
  serializeToKconfConfig = configAttrs: lib.concatLines
    (lib.mapAttrsToList
      (kconfOption: answer:
        let
          optionName = "CONFIG_${kconfOption}";
          kconfLine =
            if answer ? freeform then
              if (lib.isString answer.freeform
                || lib.isPath answer.freeform
                || lib.isDerivation answer.freeform
              ) &&
              !(lib.hasPrefix "0x" answer.freeform)
              && (builtins.match "[0-9]+" answer.freeform == null) then
                "${optionName}=\"${answer.freeform}\""
              else
                "${optionName}=${toString answer.freeform}"
            else
              assert answer ? tristate;
              # We are reusing the existing `lib.kernel` options, but u-boot
              # does not have anything similar to linux kernel modules.
              assert answer.tristate != "m";
              if answer.tristate == null then
                "# ${optionName} is not set"
              else
                "${optionName}=${toString answer.tristate}"
          ;
        in
        kconfLine
      )
      configAttrs);

  extraConfig = serializeToKconfConfig extraStructuredConfig;
in
stdenv.mkDerivation (finalAttrs: (initialArgs // {
  pname = "uboot-${boardName}";
  version = "2024.04";

  src = fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IlaDdjKq/Pq2orzcU959h93WXRZfvKBGDO/MFw9mZMg=";
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
    pyopenssl
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

