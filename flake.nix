{
  description = "A collection of nifty utility functions";

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
        # TODO Recursion Depth
        # TODO Refactor to listFilesRecursive path, suffix:
        listNixFilesRecursive =
          path:
          nixpkgs.lib.filter (f: nixpkgs.lib.hasSuffix ".nix" f) (
            nixpkgs.lib.filesystem.listFilesRecursive path
          );
        listNonNixFilesRecursive =
          path:
          nixpkgs.lib.filter (f: !nixpkgs.lib.hasSuffix ".nix" f) (
            nixpkgs.lib.filesystem.listFilesRecursive path
          );
        listDefaultNixFilesRecursive =
          path:
          nixpkgs.lib.filter (f: nixpkgs.lib.hasSuffix "default.nix" f) (
            nixpkgs.lib.filesystem.listFilesRecursive path
          );
      };
    };
}
