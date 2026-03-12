# Eden Nix Flake

Diese Flake baut `eden` reproduzierbar in der Nix-Sandbox, ohne dass CPM zur Build-Zeit aus dem Netz laden muss.

## Struktur

- `flake.nix`: Inputs und Verdrahtung
- `nix/eden-package.nix`: eigentliche Paketdefinition (ausgelagert)

## Build

```bash
nix build .#eden
```

## Neues (CPM-)Paket einpflegen

Wenn Eden ein weiteres Paket via CPM herunterladen will, gibt es zwei Wege.

### 1) Systempaket aus `nixpkgs` nutzen (bevorzugt)

1. Paket in `buildInputs` in `nix/eden-package.nix` aufnehmen.
2. In `cmakeFlags` den passenden Force-Flag setzen, z. B.:

```nix
"-D<name>_FORCE_SYSTEM=ON"
```

Beispiele, die schon gesetzt sind:
- `xbyak_FORCE_SYSTEM`
- `unordered_dense_FORCE_SYSTEM`
- `simpleini_FORCE_SYSTEM`

### 2) Quellcode als Flake-Input einbinden (`*_CUSTOM_DIR`)

Nützlich, wenn kein passendes CMake-Systempaket verfügbar ist.

1. Input in `flake.nix` unter `inputs` hinzufügen, z. B.:

```nix
foo-src = {
  url = "git+https://github.com/org/foo?rev=<voller-commit-sha>";
  flake = false;
};
```

2. Input in den `outputs`-Argumenten ergänzen.
3. Eintrag in `cpmCustomSources` in `flake.nix` hinzufügen:

```nix
{
  name = "foo";
  src = foo-src;
  dir = "foo";
  cmakeVar = "foo_CUSTOM_DIR";
}
```

Das wird automatisch in `nix/eden-package.nix` nach `$TMPDIR/foo` kopiert und als `-Dfoo_CUSTOM_DIR=...` an CMake übergeben.

## Lockfile aktualisieren

Nach neuen Inputs:

```bash
nix flake update --update-input <input-name>
```

## Typische Fehler

- `Could not resolve host`: CPM versucht noch Netzwerkzugriff -> fehlendes `*_FORCE_SYSTEM=ON` oder fehlendes `*_CUSTOM_DIR`.
- `ref=...` findet nichts: bei Git-Tags besser `rev=<voller 40-stelliger SHA>` verwenden.
