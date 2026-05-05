{
  description = "Nix flake for Eden, Commet, and T3 Code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    eden-src = {
      url = "git+https://git.eden-emu.dev/eden-emu/eden?ref=master";
      flake = false;
    };
    # CPM deps that are often missing in nixpkgs as ready CMake packages
    mcl-src = {
      url = "git+https://github.com/azahar-emu/mcl?rev=7b08d83418f628b800dfac1c9a16c3f59036fbad";
      flake = false;
    };
    sirit-src = {
      url = "git+https://github.com/eden-emulator/sirit?rev=4aa0fe9f2ca0b31d8345f89c8ca2757156ff2393";
      flake = false;
    };
    httplib-src = {
      url = "git+https://github.com/yhirose/cpp-httplib?ref=refs/tags/v0.37.0";
      flake = false;
    };
    frozen-src = {
      url = "git+https://github.com/serge-sans-paille/frozen?rev=61dce5ae18ca59931e27675c468e64118aba8744";
      flake = false;
    };
    tzdb-src = {
      url = "https://git.crueter.xyz/misc/tzdb_to_nx/releases/download/121125/121125.tar.gz";
      flake = false;
    };
  };
  outputs = {
    nixpkgs,
    flake-utils,
    eden-src,
    mcl-src,
    sirit-src,
    httplib-src,
    frozen-src,
    tzdb-src,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      inherit (pkgs) lib;
      packageSet = import ./nix/packages {
        inherit
          pkgs
          eden-src
          mcl-src
          sirit-src
          httplib-src
          frozen-src
          tzdb-src
          ;
      };
      availablePackages = lib.filterAttrs (_: drv: lib.meta.availableOn pkgs.stdenv.hostPlatform drv) packageSet;
      packages =
        availablePackages
        // lib.optionalAttrs (availablePackages ? eden) {
          default = packageSet.eden;
        };
      mkApp = drv: exePath: {
        type = "app";
        program = "${drv}${exePath}";
        inherit (drv) meta;
      };
    in {
      inherit packages;

      apps = lib.mapAttrs (name: drv: mkApp drv "/bin/${drv.meta.mainProgram or name}") availablePackages;

      formatter = pkgs.alejandra;

      devShells.default = import ./nix/shell.nix {
        inherit pkgs;
      };
    });
}
