{
  bc,
  bison,
  dtc,
  fetchFromGitHub,
  flex,
  gnutls,
  jq,
  lib,
  libuuid,
  ncurses,
  openssl,
  perl,
  pkgsBuildBuild,
  python3,
  stdenv,
  swig,
  which,
  xxd,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [ "boardName" ];

  extendDrvArgs =
    finalAttrs:
    {
      # The name of the board. This should match the filename of the defconfig
      # in the `configs` directory, without the "_defconfig" suffix.
      boardName,

      # File paths to install in the nix output in the install phase.
      artifacts ? [ ],

      # Any desired kconfig configuration. This will be merged with the
      # defconfig prior to running the `olddefconfig` make target.
      kconfig ? { },
      ...
    }@prevAttrs:
    {
      inherit kconfig artifacts;

      pname = prevAttrs.pname or "uboot-${boardName}";
      version = prevAttrs.version or "2025.10";

      src =
        prevAttrs.src or (fetchFromGitHub {
          owner = "u-boot";
          repo = "u-boot";
          rev = "v${finalAttrs.version}";
          hash = "sha256-9y21xYwJ/ATFikCRuhalKjAhpRHmOZv6a7GDkLhbon4=";
        });

      __structuredAttrs = true;

      postPatch = ''
        patchShebangs tools scripts
        ${prevAttrs.postPatch or ""}
      '';

      hardeningDisable = [ "all" ];

      enableParallelBuilding = true;

      depsBuildBuild = [
        pkgsBuildBuild.stdenv.cc
        pkgsBuildBuild.efitools # TODO(jared): for some reason doesn't work when callPackage'd
      ]
      ++ prevAttrs.depsBuildBuild or [ ];

      nativeBuildInputs = [
        bc
        bison
        dtc
        flex
        gnutls
        jq
        libuuid
        ncurses
        openssl
        perl
        swig
        which
        xxd
        (python3.pythonOnBuildForHost.withPackages (
          p: with p; [
            libfdt
            pyelftools
            pyopenssl
            setuptools
          ]
        ))
      ]
      ++ prevAttrs.nativeBuildInputs or [ ];

      makeFlags = [ "CROSS_COMPILE=${stdenv.cc.targetPrefix}" ] ++ prevAttrs.makeFlags or [ ];

      env.NIX_CFLAGS_COMPILE = "-fomit-frame-pointer";

      configurePhase = ''
        runHook preConfigure

        ${
          if lib.isPath finalAttrs.kconfig then
            ''install -Dm0644 ${finalAttrs.kconfig} .config''
          else
            ''
              python ${./kconfig.py} > extra.config
              bash ${./merge_config.bash} configs/${boardName}_defconfig extra.config
            ''
        }

        make olddefconfig
        runHook postConfigure
      '';

      installPhase = ''
        runHook preInstall

        ${lib.concatMapStrings (file: ''
          install -Dm0644 --target-directory=$out ${file}
        '') (finalAttrs.artifacts ++ [ ".config" ])}

        runHook postInstall
      '';
    };
}
