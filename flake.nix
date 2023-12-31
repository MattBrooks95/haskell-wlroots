{
  description = "haskell bindings to wlroots";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        hPkgs = pkgs.haskell.packages."ghc96";

        myDevTools = [
          hPkgs.cabal-install
          hPkgs.haskell-language-server
          hPkgs.hlint
          hPkgs.ghcid
          hPkgs.implicit-hie # auto generate LSP hie.yaml file from cabal
          pkgs.zlib # External C library needed by some Haskell packages
        ];
        externalLibraries = [
          pkgs.wlroots
          pkgs.wayland
        ];
        libraryPathItems = myDevTools ++ externalLibraries;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = libraryPathItems;
          nativeBuildInputs = [
            # necessary so wlrroots can find libudev
            pkgs.pkg-config
            # necessary so wlrroots can find libudev
            pkgs.systemd
          ];

          # Make external Nix c libraries like zlib known to GHC, like
          # pkgs.haskell.lib.buildStackProject does
          # https://github.com/NixOS/nixpkgs/blob/d64780ea0e22b5f61cd6012a456869c702a72f20/pkgs/development/haskell-modules/generic-stack-builder.nix#L38
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libraryPathItems;
        };
      }
    );
}
