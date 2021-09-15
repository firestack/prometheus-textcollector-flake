{
  description = "Packages textfile collector scripts";

  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.scripts = {
    url = "github:prometheus-community/node-exporter-textfile-collector-scripts";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, scripts }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: {
      packages =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlay (_:_:{ inherit scripts; })];
          };
        in {
          inherit (pkgs) smartmon-py;
        };

        apps = {
          smartmon-py = {
            type = "app";
            description = "smartmon-py";
            program = "${self.packages.${system}.smartmon-py.meta.mainProgram}";
          };
        };

        defaultPackage = self.packages.${system}.smartmon-py;
        defaultApp = self.apps.${system}.smartmon-py;
    }) // {
      checks = self.packages;

      overlay = final: prev: {
        smartmon-py = final.callPackage ./smartmon.py {};
      };

      nixosModules.smartmon-py = import ./smartmon.py/module.nix;
    };
}
