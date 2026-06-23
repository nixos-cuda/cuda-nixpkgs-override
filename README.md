# cuda-nixpkgs-override

> [!IMPORTANT]
>
> This repository is provided as-is. Use it at your own risk.

A flake to enable quick overriding of CUDA manifests vendored in Nixpkgs. Out-of-tree users may find `mkOverlay.nix` useful.

Manifests for different components are provided by `url` and `sh256` in `redistrib.nix`. The relative path of manifest entries are expected to be relative to the URL of the manifest.

This flake exposes `legacyPackages` (a re-export of Nixpkgs) with a CUDA package set named `cudaPackages_x_y`, where `x` and `y` are the major and minor version components of the CUDA component. The aliases `cudaPackages_x` and `cudaPackages` are also set for convenience -- as such, the CUDA package set created within our flake becomes the default CUDA package set.
