# Nix Build Workspace

This repository packages a small set of desktop applications with Nix:

- `eden`
- `commet`
- `t3code`

The layout is organized so each concern has one obvious home:

- `flake.nix`: top-level inputs and output wiring
- `nix/packages/`: one file per package, plus `default.nix` for the package set
- `nix/shell.nix`: development shell dependencies
- `justfile`: common maintenance commands

## Common Commands

Build a package:

```bash
just build eden
```

If you prefer raw `nix` commands, use them after the new files are tracked in Git:

```bash
nix build .#eden
```

Build everything:

```bash
just build-all
```

Run an app:

```bash
just run commet
```

Development and checks:

```bash
just dev
just fmt
just lint
just check
```

## Adding or Updating Packages

To add another package, keep the change surface small:

1. Add a new file under `nix/packages/<name>.nix`.
2. Export it from `nix/packages/default.nix`.
3. Add `apps.<name>` in `flake.nix` if it should be runnable with `nix run`.
4. Use the generic `just build <name>` and `just run <name>` commands. Add explicit aliases only if they improve discoverability.

## Eden CPM Sources

`eden` needs a few dependencies supplied outside `nixpkgs`. Those source mappings live in `nix/packages/default.nix`, while the actual Eden build logic lives in `nix/packages/eden.nix`.

When Eden starts requesting another CPM dependency, prefer this order:

1. Use a package from `nixpkgs` and add the matching `*_FORCE_SYSTEM=ON` CMake flag.
2. If no usable system package exists, add a new flake input and register it in the `cpmCustomSources` list.

## Updating Inputs

Update everything:

```bash
just update
```

Update one input:

```bash
just update-input eden-src
```
