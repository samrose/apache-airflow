{
  inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      flake = false;
    };
    mach-nix = {
      url = "github:DavHau/mach-nix/3.5.0";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, pypi-deps-db, mach-nix }@inp:
    let
      l = nixpkgs.lib // builtins;
      supportedSystems = [ "x86_64-linux"];
      forAllSystems = f: l.genAttrs supportedSystems
        (system: f system (import nixpkgs {inherit system;}));
    in
    {
      # enter this python environment by executing `nix shell .`
      defaultPackage = forAllSystems (system: pkgs: mach-nix.lib."${system}".mkPython {
        requirements = ''
          apache-airflow
	  gunicorn
        '';
      });
    };
}
