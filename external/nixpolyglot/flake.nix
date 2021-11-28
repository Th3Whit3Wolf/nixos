{
  description = "Modules to help developers get work done";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    rust.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust, ... }@inputs:
    let
      overlay = final: prev: (import ./overlays);
      overlays = [ rust.overlay overlay ];
      pkgs = import nixpkgs { inherit overlays; };
    in  {
      overlay = import ./overlays;

      nixosModules.home-manager.nixpolyglot =
        import ./modules/home-manager/default.nix inputs;
    };

}

