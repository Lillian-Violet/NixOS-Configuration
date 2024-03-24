{
  description = "NixOS configuration for Lillian Violet's systems";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Disko for declaratively setting disk formatting
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Nixos generators for creating ISOs
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Conduit fork without all the fuss and drama
    conduit = {
      url = "github:girlbossceo/conduwuit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management with sops
    sops-nix.url = "github:Mic92/sops-nix";

    # Simple mail server
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";

    # Extra utils for flakes
    flake-utils.url = "github:numtide/flake-utils";

    # Manage KDE plasma desktop configuration
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Lanzaboot (secure boot)
    lanzaboote.url = "github:nix-community/lanzaboote";

    # Jovian nixos (steam deck)
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Fix for steam cursor not being visible under wayland
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
    nixos-generators,
    disko,
    home-manager,
    sops-nix,
    simple-nixos-mailserver,
    plasma-manager,
    linger,
    pihole,
    lanzaboote,
    jovian,
    nixos-hardware,
    conduit,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "armv7l-linux"
      "x86_64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system:
      import ./pkgs (import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      }));
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      EDI = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          nixos-hardware.nixosModules.dell-xps-13-7390
          # > Our main nixos configuration file <
          ./nixos/hosts/EDI/configuration.nix
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
          }
        ];
      };

      GLaDOS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/GLaDOS/configuration.nix
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
          }
        ];
      };

      queen = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/queen/configuration.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          simple-nixos-mailserver.nixosModule
        ];
      };

      shodan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/shodan/configuration.nix
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko
          jovian.nixosModules.jovian
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
          }
        ];
      };

      ISO = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ./nixos/hosts/iso/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
          }
        ];
      };

      wheatley = nixpkgs.lib.nixosSystem {
        system = "armv7l-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          # make the module declared by the linger flake available to our config
          #linger.nixosModules."armv7l-linux".default
          #pihole.nixosModules."armv7l-linux".default
          disko.nixosModules.disko
          # > Our main nixos configuration file <
          ./nixos/hosts/wheatley/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
