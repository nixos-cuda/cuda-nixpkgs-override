redistrib:
let
  inherit (builtins)
    convertHash
    fetchurl
    fromJSON
    hashFile
    mapAttrs
    readFile
    ;
in
mapAttrs (_: { url, ... }: {
  inherit url;
  sha256 = convertHash {
    hash = hashFile "sha256" (fetchurl {
      inherit url;
    });
    hashAlgo = "sha256";
    toHashFormat = "sri";
  };
}) (fromJSON (readFile redistrib))
