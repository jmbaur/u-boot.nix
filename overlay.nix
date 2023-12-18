final: prev:
let
  ubootLib = import ./lib.nix { inherit (prev) lib; };
in
{ ubootLib = ubootLib._external; }
  // (import ./boards.nix { pkgs = prev; })
