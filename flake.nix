{
  description = "A flake for easy ingestion and use of CUDA manifests";

  inputs = {
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    git-hooks-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/git-hooks.nix";
    };
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];

      flake = {
        # mkOverlay :: { [RedistName] :: { manifest :: Manifest, url :: String } }
        #           -> (final :: Attrs)
        #           -> (prev :: Attrs)
        #           -> Attrs
        mkOverlay = import ./mkOverlay.nix;

        # fetchRedistrib :: { [RedistName] :: { sha256 :: SriHash, url :: String } }
        #                -> { [RedistName] :: { manifest :: Manifest, url :: String } }
        fetchRedistrib = builtins.mapAttrs (
          _: value: {
            inherit (value) url;
            manifest = builtins.fromJSON (builtins.readFile (builtins.fetchurl value));
          }
        );
      };

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          # Use unmodified Nixpkgs for everything, but expose legacyPackages as having our overlay applied
          _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};

          legacyPackages = import inputs.nixpkgs {
            config = {
              allowUnfree = true;
              cudaSupport = true;
              permittedInsecurePackages = [
                # CVE-2026-24188: OOB write
                "cuda13.4-tensorrt-10.14.1.48"
              ];
            };
            overlays = [
              (inputs.self.mkOverlay (
                inputs.self.fetchRedistrib (builtins.fromJSON (builtins.readFile ./redistrib.json))
              ))
            ];
            inherit system;
          };

          # NOTE: We must use `nix run .# --`, because if we specify a flake URI fragment (e.g., nix run
          # .#regenerate-redistrib), legacyPackages is searched first for the fragment, and since the default CUDA
          # package set depends on parsing the redistrib, empty or invalid hashes will cause an evaluation error.
          packages.default = pkgs.writeShellApplication {
            name = "regenerate-redistrib";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              main() {
                if (( $# != 1 )); then
                  echo "regenerate-redistrib: usage: regenerate-redistrib <path-to-redistrib.json>" >&2
                  exit 1
                fi

                local redistribPath
                redistribPath=$(realpath -- "$1")

                if [[ ! -f "$redistribPath" ]]; then
                  echo "regenerate-redistrib: no such file: $redistribPath" >&2
                  exit 1
                fi

                local originalMode
                originalMode=$(stat -c '%a' -- "$redistribPath")

                local tmpPath
                tmpPath=$(mktemp "$redistribPath.XXXXXX")
                trap 'rm -f "$tmpPath"' EXIT

                echo "Regenerating $redistribPath"

                if ! nix eval -f ${./regenerate-redistrib.nix} --apply "f: f \"$redistribPath\"" --json --pretty > "$tmpPath"; then
                  echo "regenerate-redistrib: failed to regenerate $redistribPath; original left untouched" >&2
                  exit 1
                fi
                chmod "$originalMode" -- "$tmpPath"

                local -r backupPath="$redistribPath.bak"
                cp -- "$redistribPath" "$backupPath"
                mv -- "$tmpPath" "$redistribPath"
                trap - EXIT

                echo "Regenerated $redistribPath (previous version backed up to $backupPath)"
              }

              main "$@"
            '';
          };

          pre-commit.settings.hooks = {
            # Formatter checks
            treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
            };

            # Nix checks
            deadnix.enable = true;
            nil.enable = true;
            statix.enable = true;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        };
    };
}
