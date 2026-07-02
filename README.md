# cuda-nixpkgs-override

> [!IMPORTANT]
>
> This repository is provided as-is. Use it at your own risk.

A flake to enable quick overriding of CUDA manifests vendored in Nixpkgs. Out-of-tree users may find `mkOverlay.nix` useful.

Manifests for different components are provided by `url` and `sha256` entries in `redistrib.json`. The relative path of manifest entries are expected to be relative to the URL of the manifest.

`sha256` entries are the [SRI](https://www.w3.org/TR/SRI/)-formatted flat SHA-256 hash of the file downloaded from `url` (i.e. `builtins.hashFile "sha256"` converted to `nix32`/`sri` via `builtins.convertHash`, matching what `builtins.fetchurl` verifies against) -- not a NAR hash.

This flake exposes `legacyPackages` (a re-export of Nixpkgs) with a CUDA package set named `cudaPackages_x_y`, where `x` and `y` are the major and minor version components of the CUDA component. The aliases `cudaPackages_x` and `cudaPackages` are also set for convenience -- as such, the CUDA package set created within our flake becomes the default CUDA package set.

## Updating a redistrib entry

To bump a component to a new release, edit its `url` in `redistrib.json`, then regenerate the corresponding `sha256`:

```console
nix run .# -- ./redistrib.json
```

Use `nix run .# --` (the default package), not `nix run .#regenerate-redistrib --`: since the default CUDA package set is built from `redistrib.json` as part of evaluating this flake's outputs, a flake URI fragment lookup falls back to searching `legacyPackages` first, and a stale or invalid hash there would cause an evaluation error before `packages.regenerate-redistrib` is ever reached.

The utility re-fetches every `url` in the given file and rewrites its `sha256`. It fails safely:

- The original file is only ever replaced after a successful regeneration; a failed fetch or `nix eval` leaves it untouched.
- The replacement is atomic (written to a temporary file, then renamed into place), and the file's original permissions are preserved.
- The previous contents are copied to `<path>.bak` immediately before the replacement.
