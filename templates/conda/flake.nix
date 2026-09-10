{
  description = "Conda-based project development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Nix only supplies the `conda` binary here; conda still manages its
        # own environments and packages under .conda/. Conda-managed deps
        # aren't reproducible the way Nix packages are, but this avoids a
        # manual Miniconda install and keeps everything project-local.
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            conda
          ];

          shellHook = ''
            export CONDA_ENVS_PATH="$PWD/.conda/envs"
            export CONDA_PKGS_DIRS="$PWD/.conda/pkgs"
            echo "First time in this project: conda create -p ./.conda/envs/dev python=3.11"
            echo "Then: conda activate ./.conda/envs/dev"
          '';
        };
      });
}
