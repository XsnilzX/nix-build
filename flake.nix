{
  description = "Eden emulator flake build";
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
    self,
    nixpkgs,
    flake-utils,
    eden-src,
    mcl-src,
    sirit-src,
    frozen-src,
    tzdb-src,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      cpmCustomSources = [
        {
          name = "mcl";
          src = mcl-src;
          dir = "mcl";
          cmakeVar = "mcl_CUSTOM_DIR";
        }
        {
          name = "sirit";
          src = sirit-src;
          dir = "sirit";
          cmakeVar = "sirit_CUSTOM_DIR";
        }
        {
          name = "frozen";
          src = frozen-src;
          dir = "frozen";
          cmakeVar = "frozen_CUSTOM_DIR";
        }
      ];
    in {
      packages.default = import ./nix/eden-package.nix {
        inherit pkgs cpmCustomSources;
        edenSrc = eden-src;
        tzdbPath = tzdb-src;
      };
      packages.eden = self.packages.${system}.default;
      packages.commet = import ./nix/commet-package.nix {
        inherit pkgs;
      };
      apps.default = flake-utils.lib.mkApp {
        drv = self.packages.${system}.default;
        exePath = "/bin/eden";
      };
      apps.commet = flake-utils.lib.mkApp {
        drv = self.packages.${system}.commet;
        exePath = "/bin/commet";
      };
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          self.packages.${system}.default
          self.packages.${system}.commet
        ];
      };
    });
}
