{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages = [ pkgs.git ];

  git-hooks = {
    hooks = {
      ripsecrets.enable = true;
      treefmt.enable = true;
    };
    package = pkgs.prek;
  };

  treefmt = {
    enable = true;
    config.programs = {
      nixfmt.enable = true;
      shellcheck.enable = true;
      shfmt.enable = true;
    };
  };

}
