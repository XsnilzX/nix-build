set shell := ["zsh", "-cu"]

default:
  @just --list

# Build a package from the flake outputs.
build package:
  nix build "path:$PWD#{{package}}"

# Build all packaged programs.
build-all:
  just build eden
  just build commet
  just build t3code

# Build the Eden emulator package.
build-eden:
  just build eden

# Build the Commet package.
build-commet:
  just build commet

# Build the T3 Code package.
build-t3code:
  just build t3code

# Run an app from the flake outputs.
run package:
  nix run "path:$PWD#{{package}}"

# Run the Eden emulator app.
run-eden:
  just run eden

# Run the Commet app.
run-commet:
  just run commet

# Run T3 Code.
run-t3code:
  just run t3code

# Check that the flake evaluates and all declared checks pass.
check:
  nix flake check "path:$PWD"

# Enter the default development shell.
dev:
  nix develop "path:$PWD"

# Format Nix files with alejandra.
fmt:
  alejandra flake.nix nix

# Run the configured static analysis tools.
lint:
  statix check .
  deadnix .

# Update all flake inputs.
update:
  nix flake update

# Update a specific flake input, for example: just update-input eden-src
update-input input:
  nix flake update --update-input {{input}}
