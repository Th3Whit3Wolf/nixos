/* *
   https://github.com/gytis-ivaskevicius/flake-utils-plus
   https://github.com/reckenrode/nixos-configs
   https://github.com/willruggiano/dotfiles
   https://github.com/ajgrf/dotfiles

   https://learn-2.galvanize.com/cohorts/9ce164f50c49353013
   *
*/
{
  # sudo nixos-rebuild --option sandbox false --flake .#Nebula switch
  description = "A highly awesome system configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.0";
    devshell.url = "github:numtide/devshell";
    nixpolyglot.url = "./external/nixpolyglot";

    impermanence.url =
      "github:nix-community/impermanence";

    nix-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.unstableSmall.follows = "unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.flake-utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, unstable, utils, nur, home-manager, ragenix
    , impermanence, nixpolyglot, ... }:
    let
      args = { inherit (self) lib; };
      lib' = import ./lib args inputs;
      lib =
        unstable.lib.extend (final: prev: { inherit (lib') mkHosts importers; });
      inherit (lib) recurseIntoAttrs recursiveUpdate;
      inherit (utils.lib) eachDefaultSystem flattenTree mkApp mkFlake;

      overlays = import ./overlays;
      packages = import ./pkgs;

    in mkFlake rec {
      inherit self inputs lib;

      supportedSystems = lib.mapAttrsToList (system: _: system) (
        lib.filterAttrs (_: type: type == "directory")(builtins.readDir ./hosts)
      );

  # Reference to `channels.<name>.*`, defines default channel to be used by hosts. Defaults to "nixpkgs".
  hostDefaults.channelName = "stable";

      channels.stable = {
        input = nixpkgs;
        config = { 
          allowUnfree = true;
          #allowBroken = true;
        };
	overlaysBuilder = channels: [
    overlays
    (final: prev: { nix-direnv = prev.nix-direnv.override { enableFlakes = true; }; } )
    ];
      };

      channels.unstable = {
        input = unstable;
        config = { 
          allowUnfree = true;
         # allowBroken = true; 
        };
	overlaysBuilder = channels: [overlays];
      };

      sharedOverlays = [ nur.overlay ragenix.overlay nixpolyglot.overlay ];

      hosts = lib.mkHosts {
        inherit self channels overlays;
        hostsPath = ./hosts;
      };

      outputsBuilder = channels: {
        packages =
          let
            inherit (channels.stable.stdenv.hostPlatform) system;
          in
          packages channels.stable ;

          devShell = channels.stable.mkShell {
            buildInputs = [
              channels.stable.nixpkgs-fmt
              ragenix.defaultPackage.x86_64-linux
              channels.stable.git
            ];
          };
      };

    };
}
