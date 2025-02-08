{ pkgs, myphp ? pkgs.php }:

let
  version = "0.0.1";
  revision = "dfe1ab17b0f155cc315bc13c75689371676e02e1";
  fetchFromGitHub = pkgs.fetchFromGitHub;
  buildPecl = myphp.buildPecl;
in
buildPecl {
  inherit version;

  pname = "geos";

  src = fetchFromGitHub {
    owner = "libgeos";
    repo = "php-geos";
    rev = revision;
    sha256 = "sha256-rL15bGs/8O+eUY6Rnvr6d9kvNcOXtFI9+tmrQjIzWWk=";
  };

  nativeBuildInputs = [ pkgs.pkg-config pkgs.geos ];
  buildInputs = [ pkgs.geos ];

  configureFlags = [ ];

  doCheck = false;

  meta = {
    changelog = "https://github.com/libgeos/php-geos/commit/${revision}";
    description = "PHP bindings for libgeos";
  };
}
