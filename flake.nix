{
  description = "Erlang, Elixir, Flyctl, Node.js, and PostgreSQL Development Environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          {
            devShells.default = pkgs.mkShell {
              name = "erlang-elixir-dev";
              packages = with pkgs; [
                elixir_1_15
                flyctl
                nodejs
                postgresql_14 # Or your preferred PostgreSQL version
              ];
            };
          }
      );
}
