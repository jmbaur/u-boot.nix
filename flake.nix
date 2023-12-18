{
  description = "u-boot configuration within nix";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: {
    overlays.default = import ./overlay.nix;
    checks = nixpkgs.lib.mapAttrs
      (system: pkgs: import ./checks.nix { inherit pkgs; })
      self.legacyPackages;
    legacyPackages = nixpkgs.lib.genAttrs
      [ "x86_64-linux" "aarch64-linux" ]
      (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      });
  };
}
