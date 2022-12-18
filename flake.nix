{
  description = "Haskell bindings for secp256k1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkg-name = "secp256k1-haskell";
        pkgs = import nixpkgs {
          inherit system;
        };

        haskell = pkgs.haskellPackages;

        haskell-overlay = final: prev: {
          ${pkg-name} = hspkgs.callCabal2nix pkg-name ./. { };
          secp256k1 = pkgs.secp256k1;
        };

        hspkgs = haskell.override {
          overrides = haskell-overlay;
        };
      in {
        packages = pkgs;

        defaultPackage = hspkgs.${pkg-name};

        devShell = hspkgs.shellFor {
          packages = p: [p.${pkg-name}];
          root = ./.;
          withHoogle = true;
          buildInputs = with hspkgs; [
            haskell-language-server
            cabal-install
            pkgs.secp256k1
          ];
        };
      });
}
