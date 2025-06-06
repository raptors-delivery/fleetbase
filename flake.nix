{
  description = "Fleetbase development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        stdenv = pkgs.stdenv;
        myphp = pkgs.php83.override {
          embedSupport = true;
          ztsSupport = true;
          staticSupport = stdenv.hostPlatform.isDarwin;
          zendSignalsSupport = false;
          zendMaxExecutionTimersSupport = stdenv.hostPlatform.isLinux;
        };
        geos = pkgs.callPackage ./nix/php/geos.nix {
          inherit myphp;
        };
        php = myphp.buildEnv {
          extensions = (
            { enabled, all }:
            enabled
            ++ (with all; [
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
            ])
          );
          extraConfig = ''
            date.timezone = "UTC"
            # turn off xdebug by default
            xdebug.mode=off
            #xdebug.mode=debug,develop
            #xdebug.start_with_request=yes
            #xdebug.start_upon_error=yes
            #xdebug.idekey=VSCODE
          '';
        };

        frankenphp = pkgs.frankenphp.override {
          inherit php;
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
            pkgs.watchman

            php
            frankenphp
            php.packages.composer
            php.packages.php-cs-fixer
            php.packages.phpstan
            pkgs.blade-formatter
            pkgs.laravel
            pkgs.phpactor
          ];
          packages = [ ];
        };
      }
    );
}
