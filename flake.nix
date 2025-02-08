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
        myphp = pkgs.php82;
        geos = pkgs.callPackage ./nix/php/geos.nix {
          inherit myphp;
        };
        php = myphp.buildEnv {
          extensions = ({ enabled, all }: enabled ++ (with all; [
            # Add More PHP Extensions Here
            xdebug
            gd
            redis
            pdo
            pdo_mysql
            gmp
            imagick
            bcmath
            opcache
            intl
            memcached
            sockets
            pcntl
            zip
            apcu
            geos
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
            php.packages.composer
            php.packages.php-cs-fixer
            php.packages.phpstan
            pkgs.blade-formatter
            pkgs.laravel
            pkgs.phpactor
          ];
          packages = [ ];
        };
      });
}
