{
  description = "A collection of nix utility functions";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      systems,
      ...
    }:

    {
      formatter = self.lib.forAllSystems (pkgs: self.lib.treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = self.lib.forAllSystems (pkgs: {
        formatting = self.lib.treefmtEval.${pkgs.system}.config.build.check self;
      });

      devShells = self.lib.forAllSystems (pkgs: {
        default = pkgs.mkShell { packages = [ ]; };
      });

      lib = {
        forAllSystems =
          function: nixpkgs.lib.genAttrs (import systems) (system: function nixpkgs.legacyPackages.${system});
        treefmtEval = self.lib.forAllSystems (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
        listNixModules =
          path:
          builtins.map (f: ./${f}) (
            builtins.attrNames (
              nixpkgs.lib.filterAttrs (n: v: nixpkgs.lib.hasSuffix ".nix" n || v == "directory") (
                builtins.readDir path
              )
            )
          );
        matchFilesRecursive =
          path: condition:
          nixpkgs.lib.filter (f: condition f) (nixpkgs.lib.filesystem.listFilesRecursive path);
        excludeFilesRecursive =
          path: condition:
          nixpkgs.lib.filter (f: !condition f) (nixpkgs.lib.filesystem.listFilesRecursive path);
      };
    };
}
