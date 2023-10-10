{
  description = "marp-nix";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2105.296223.tar.gz";

  outputs =
    { self
    , nixpkgs
    , ...
    } @ inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      allSystems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" ];

      forAllSystems = f: genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShell = forAllSystems ({ system, pkgs, ... }:
        pkgs.mkShell {
          name = "marp";

          buildInputs = with pkgs; [
            nixpkgs-fmt
            findutils # find, xargs
            codespell
          ] ++ [
            self.defaultPackage.${system}
          ];
        });

      packages = forAllSystems
        ({ system, pkgs, ... }: {
          marp = pkgs.callPackage ./marp.nix {
            inherit (import ./default.nix { inherit pkgs; })
              nodeDependencies;
          };
        });

      defaultPackage = forAllSystems ({ system, ... }: self.packages.${system}.marp);
    };
}
