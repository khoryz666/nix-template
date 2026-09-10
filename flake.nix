{
  description = "Personal Nix flake templates";

  outputs = { self }: {
    templates = {
      default = {
        path = ./templates/default;
        description = "Generic per-project dev shell (Nix + direnv, empty packages list)";
      };
      python = {
        path = ./templates/python;
        description = "Python dev shell (python3, pip, venv)";
      };
      conda = {
        path = ./templates/conda;
        description = "Conda dev shell (Nix-provided conda binary)";
      };
      rust = {
        path = ./templates/rust;
        description = "Rust dev shell (rustc, cargo, clippy, rust-analyzer)";
      };
      golang = {
        path = ./templates/golang;
        description = "Go dev shell (go, gopls, golangci-lint, delve)";
      };
      java = {
        path = ./templates/java;
        description = "Java dev shell (jdk21, maven, gradle)";
      };
      npm = {
        path = ./templates/npm;
        description = "Node.js dev shell (nodejs_22 + npm)";
      };
      c = {
        path = ./templates/c;
        description = "C dev shell (gcc, gnumake, cmake, gdb, clangd)";
      };
      cpp = {
        path = ./templates/cpp;
        description = "C++ dev shell (gcc/g++, gnumake, cmake, gdb, clangd)";
      };
    };
  };
}
