{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mnw.url = "github:Gerg-L/mnw";
  };

  outputs =
    {
      self,
      nixpkgs,
      mnw,
    }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems =
        function: lib.genAttrs supportedSystems (system: function nixpkgs.legacyPackages.${system});

    in
    {
      packages = forAllSystems (pkgs: {
        default = import ./default.nix { inherit pkgs mnw; };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            self.packages.${pkgs.stdenv.hostPlatform.system}.default.devMode
            pkgs.nixfmt
            pkgs.stylua
            pkgs.nil
            pkgs.lua-language-server
          ];
        };
      });

    };
}
