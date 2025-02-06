{
  description = "Fleetbase development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        phpPackages = pkgs.php83Packages;
        php = pkgs.php83.buildEnv {
          extensions = ({ enabled, all }: enabled ++ (with all; [
            # Add More PHP Extensions Here
            xdebug
          ]));
          extraConfig = ''
            date.timezone = "UTC"
            xdebug.mode=debug
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "fleetbase";
          nativeBuildInputs = [ ];
          buildInputs = [
            # Nodejs
            pkgs.nodePackages.typescript-language-server
            pkgs.nodejs_22
            pkgs.pnpm

            php
            phpPackages.composer
            phpPackages.php-cs-fixer
            phpPackages.phpstan
            pkgs.blade-formatter
            pkgs.laravel
            pkgs.phpactor
          ];
          packages = [ ];
        };
      });
}
