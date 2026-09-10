{
  description = "Java project development environment";

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
        devShells.default = pkgs.mkShell {
          # Both build tools are listed since projects vary; delete the one
          # you don't use.
          packages = with pkgs; [
            jdk21
            maven
            gradle
          ];
        };
      });
}
