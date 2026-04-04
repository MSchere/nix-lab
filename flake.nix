{
  description = "NixOS configuration for nix-lab LXC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tiponero = {
      url = "github:tiponero/tiponero-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, tiponero }: {
    # Expose agenix CLI for encrypting/editing secrets
    packages.x86_64-linux.agenix = agenix.packages.x86_64-linux.default;

    nixosConfigurations.nix-lab = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit tiponero; };
      modules = [
        agenix.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
