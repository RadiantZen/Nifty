{
  projectRootFile = "flake.nix";
  settings.global.excludes = [ ".direnv/*" ];
  programs = {
    nixfmt = {
      enable = true;
      strict = true;
    };
    shellcheck = {
      enable = true;
    };
  };
}
