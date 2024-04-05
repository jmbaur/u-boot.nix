{
  description = "u-boot configuration within nix";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    {
      formatter = nixpkgs.lib.mapAttrs (_: pkgs: pkgs.nixfmt-rfc-style) self.legacyPackages;
      overlays.default = import ./overlay.nix;
      checks = nixpkgs.lib.mapAttrs (_: pkgs: import ./checks.nix { inherit pkgs; }) self.legacyPackages;
      legacyPackages =
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
          (
            system:
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
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
