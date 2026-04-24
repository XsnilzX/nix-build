{pkgs}: let
  inherit (pkgs) lib;
in
  pkgs.mkShell {
    packages =
      (with pkgs; [
        codex
        alejandra
        statix
        deadnix
        just
      ])
      ++ lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.opencode) [
        pkgs.opencode
      ];
  }
