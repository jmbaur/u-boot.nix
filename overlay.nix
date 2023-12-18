final: prev:
let
  boards = import ./boards.nix { pkgs = prev; };

  ubootLib = import ./lib.nix { inherit (prev) lib; };
in
builtins.listToAttrs (map
  ({ name, value }:
  prev.lib.nameValuePair
    "uboot-${name}"
    (prev.callPackage ./u-boot.nix {
      boardName = name;
      inherit ubootLib;
      inherit (value) artifacts extraMakeFlags arch;
    })
  )
  boards)
