# redistrib :: { [RedistName] :: { manifest :: Manifest, url :: String } }
redistrib: final: prev:
let
  inherit (builtins)
    concatStringsSep
    elemAt
    getAttr
    hasAttr
    mapAttrs
    splitVersion
    ;

  cudaVersionComponents = splitVersion redistrib.cuda.manifest.release_label;
  cudaPackageSetMajorName = concatStringsSep "_" [
    "cudaPackages"
    (elemAt cudaVersionComponents 0)
  ];
  cudaPackageSetMajorMinorName = cudaPackageSetMajorName + "_" + elemAt cudaVersionComponents 1;
in
{
  # Top-level fix-point used in `cudaPackages`' internals
  _cuda = prev._cuda.extend (
    finalCuda: prevCuda: {
      # Kept for visibility, not for use.
      inherit redistrib;

      # Manifests from upstream are clobbered by ones from redistrib at the granularity of the version of the manifest.
      manifests =
        let
          # Nest each of the redistrib manifest from our flake inputs under the version of the relase to match our
          # manifests format.
          ourManifests = mapAttrs (_: value: {
            ${value.manifest.release_label} = value.manifest;
          }) redistrib;
        in
        mapAttrs (name: value: value // ourManifests.${name} or { }) (ourManifests // prevCuda.manifests);

      lib = prevCuda.lib // {
        # NOTE: Modified to use URLs from our redistrib attribute when available.
        mkRedistUrl =
          let
            # Use the strategy pattern so it's memoized
            strategy = mapAttrs (
              redistName: _:
              if hasAttr redistName redistrib then
                # Manifests provided through redistrib may be at non-standard locations; we need to derive the actual
                # prefix to use.
                relativePath: (dirOf (getAttr redistName redistrib).url) + "/" + relativePath
              else
                prevCuda.lib.mkRedistUrl redistName
            ) finalCuda.manifests;
          in
          redistName: relativePath: (getAttr redistName strategy) relativePath;
      };
    }
  );

  # Make our package set the default version.
  cudaPackages = getAttr cudaPackageSetMajorName final;

  ${cudaPackageSetMajorName} = getAttr cudaPackageSetMajorMinorName final;

  ${cudaPackageSetMajorMinorName} =
    let
      mkCudaPackages =
        manifestVersions:
        final.callPackage final._cuda.bootstrapData.cudaPackagesPath {
          manifests = final._cuda.lib.selectManifests manifestVersions;
        };
    in
    mkCudaPackages (
      mapAttrs (_: r: r.manifest.release_label) redistrib
      // {
        # NOTE: Have not yet found/switched to the TensorRT redistrib manifest (have previously had to create my own).
        tensorrt = "10.14.1";
      }
    );
}
