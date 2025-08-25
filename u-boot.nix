{
  bc,
  bison,
  fetchFromGitHub,
  flex,
  gnutls,
  lib,
  libuuid,
  ncurses,
  openssl,
  pkgsBuildBuild,
  python3Packages,
  stdenv,
  swig,
  which,
  writeText,
  xxd,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "boardName"
    "artifacts"
    "kconfig"
  ];

  extendDrvArgs =
    finalAttrs:
    # TODO(jared): document these options
    {
      boardName,
      artifacts ? [ ],
      kconfig ? { },
      ...
    }@args:

    let
      serializeToKconfConfig =
        configAttrs:
        lib.concatLines (
          lib.mapAttrsToList (
            kconfOption: answer:
            let
              optionName = "CONFIG_${kconfOption}";
              kconfLine =
                if answer ? freeform then
                  if
                    (
                      (lib.isPath answer.freeform || lib.isDerivation answer.freeform)
                      || (lib.isString answer.freeform && builtins.match "[0-9]+" answer.freeform == null)
                    )
                    && !(lib.hasPrefix "0x" answer.freeform)
                  then
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
                    "${optionName}=${toString answer.tristate}";
            in
            kconfLine
          ) configAttrs
        );

      extraConfig = writeText "${boardName}-extra-config" (serializeToKconfConfig kconfig);
    in
    {
      pname = "uboot-${boardName}";
      version = "2025.07";

      src = fetchFromGitHub {
        owner = "u-boot";
        repo = "u-boot";
        rev = "v${finalAttrs.version}";
        hash = "sha256-X+JhVkDudkvQo08hGwAChOeMZZR+iunT9aU6tSAuMmg=";
      };

      postPatch = ''
        patchShebangs tools scripts
        ${args.postPatch or ""}
      '';

      hardeningDisable = [ "all" ];

      enableParallelBuilding = true;

      depsBuildBuild = [ pkgsBuildBuild.stdenv.cc ] ++ args.depsBuildBuild or [ ];

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
      ]
      ++ (with python3Packages; [
        libfdt
        pyelftools
        pyopenssl
        setuptools
      ])
      ++ args.nativeBuildInputs or [ ];

      makeFlags = [
        "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
        "DTC=${lib.getExe' pkgsBuildBuild.dtc "dtc"}"
      ]
      ++ args.makeFlags or [ ];

      env.NIX_CFLAGS_COMPILE = "-fomit-frame-pointer";

      configurePhase = ''
        runHook preConfigure

         ${
           if lib.isPath kconfig then
             ''
               install -Dm0644 ${kconfig} .config
             ''
           else
             ''
               bash ${./merge_config.bash} configs/${boardName}_defconfig ${extraConfig}
             ''
         }

        make olddefconfig
        runHook postConfigure
      '';

      installPhase = ''
        runHook preInstall

        ${lib.concatMapStrings (file: ''
          install -Dm0644 --target-directory=$out ${file}
        '') (artifacts ++ [ ".config" ])}

        runHook postInstall
      '';
    };
}
