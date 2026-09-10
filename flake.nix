{
  description = "Personal Nix flake templates";

  outputs = { self }: {
    templates.default = {
      path = ./templates/default;
      description = "Generic per-project dev shell (Nix + direnv, empty packages list)";
    };
  };
}
