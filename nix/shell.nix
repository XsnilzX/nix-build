{pkgs}:
pkgs.mkShell {
  packages = with pkgs; [
    codex
    alejandra
    statix
    deadnix
    opencode
    just
  ];
}
