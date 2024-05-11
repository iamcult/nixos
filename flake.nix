{
  description = "flake for thing";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, agenix, lanzaboote }: {
    nixosConfigurations = {
      thing = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          impermanence.nixosModules.impermanence
          lanzaboote.nixosModules.lanzaboote
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.cult = import ./home.nix;
          }
        ];
      };
    };
  };
}
