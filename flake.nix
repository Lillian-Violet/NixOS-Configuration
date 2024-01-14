{
  description = "NixOS configuration for Lillian Violet's systems";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
    flake-utils.url = "github:numtide/flake-utils";
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    extest.url = "github:chaorace/extest-nix";
    # Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Required for making sure that Pi-hole continues running if the executing user has no active session.
    linger = {
      url = "github:mindsbackyard/linger-flake";
      inputs.flake-utils.follows = "flake-utils";
    };

    pihole = {
      url = "github:mindsbackyard/pihole-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.linger.follows = "linger";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    simple-nixos-mailserver,
    plasma-manager,
    linger,
    pihole,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      EDI = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/EDI/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };

    nixosConfigurations = {
      GLaDOS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/GLaDOS/configuration.nix
          sops-nix.nixosModules.sops
          #plasma-manager.homeManagerModules.plasma-manager
          home-manager.nixosModules.home-manager
        ];
      };
    };

    nixosConfigurations = {
      queen = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/queen/configuration.nix
          sops-nix.nixosModules.sops
          simple-nixos-mailserver.nixosModule
        ];
      };
    };

    nixosConfigurations = {
      shodan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/shodan/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
    nixosConfigurations = {
      wheatley = nixpkgs.lib.nixosSystem {
        system = "armv7l-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # make the module declared by the linger flake available to our config
          #linger.nixosModules."armv7l-linux".default
          #pihole.nixosModules."armv7l-linux".default

          # > Our main nixos configuration file <
          ./nixos/hosts/wheatley/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
