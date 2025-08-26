{
  description = "u-boot configuration within nix";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs.lib)
        composeManyExtensions
        genAttrs
        mapAttrs
        ;
    in
    {
      formatter = mapAttrs (
        _: pkgs:
        pkgs.treefmt.withConfig {
          runtimeInputs = [ pkgs.nixfmt ];
          settings.formatter.nixfmt.command = "nixfmt";
          settings.formatter.nixfmt.includes = [ "*.nix" ];
        }
      ) inputs.self.legacyPackages;
      overlays.default = composeManyExtensions [
        (final: prev: {
          makeUBoot = final.callPackage ./u-boot.nix { };
          imxFirmware = final.callPackage ./misc/imx-firmware.nix { };
          armTrustedFirmwareImx8mm = final.callPackage ./misc/imx8mm-arm-trusted-firmware.nix { };
          armTrustedFirmwareImx8mp = final.callPackage ./misc/imx8mp-arm-trusted-firmware.nix { };
        })
        (import ./boards.nix)
      ];
      checks = mapAttrs (
        _: pkgs:
        (import ./checks.nix { inherit pkgs; })
        // {
          kconfig-py =
            pkgs.runCommand "kconfig-py-check"
              {
                nativeBuildInputs = [ pkgs.python3.pkgs.pytest ];
              }
              ''
                pytest ${./kconfig.py}
                touch $out
              '';
        }
      ) inputs.self.legacyPackages;
      devShells = mapAttrs (system: pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [
            (
              {
                "x86_64-linux" = pkgs.uboot-qemu-x86;
                "aarch64-linux" = pkgs.uboot-qemu_arm64;
              }
              .${system}
            )
          ];
        };
      }) inputs.self.legacyPackages;
      legacyPackages =
        genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
          (
            system:
            import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.self.overlays.default ];
              config.allowUnfreePredicate =
                pkg:
                builtins.elem pkg.pname [
                  "arm-trusted-firmware-rk3588"
                  "imx-firmware"
                  "rkbin"
                ];
            }
          );
    };
}
