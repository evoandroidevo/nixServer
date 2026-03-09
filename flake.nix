{
  description = "Nix config for Docker Server";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-25.05";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs.config.allowUnfree = true;
      prefix = "nix";
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.nix-topology.overlays.default ];
      };

      topology = import inputs.nix-topology {
        inherit pkgs;
        modules = [
          # Your own file to define global topology. Works in principle like a nixos module but uses different options.
          ./nix/topology.nix
          # Inline module to inform topology of your existing NixOS hosts.
          { inherit (inputs.self) nixosConfigurations; }
        ];
      };
    });
}
