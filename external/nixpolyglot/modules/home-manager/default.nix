{ self, ... }@inputs:
{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  inherit (lib) mkDefault mkIf mkOption mkOpt types;

  cfg = config.home.nix-polyglot;
  languages = flatten
    (mapAttrsToList (name: type: if type == "directory" then "${name}" else "")
      (readDir (./lang))) ++ [ "all" ];

  polyglotPackages = with pkgs; [ git-ignore
   #licensor 
   just dotenv-linter ];

  system = "x86_64-linux";
  overlay = import ../../overlays;
  overlays = [overlay inputs.rust.overlay];
  overlayPkgs = import inputs.nixpkgs {inherit system overlays;};

  importLanguages = (import ./lang {inherit overlayPkgs;});
in
{
  imports = [ ./neovim.nix ./vscode  importLanguages  ];

  /*
    * Should have strong integrations with many editors
    * VSCODE   - In Progress
    * NVIM     - Started
    * EMACS    - Not Started
    * KAKOUNE  - Not Started
    * HELIX    - Not Started

    Browser extension:
    * Github: https://github.com/stefanbuck/awesome-browser-extensions-for-github
    * react devtools - nur.repos.rycee.firefox-addons.react-devtools
    * vue devtools - https://github.com/vuejs/devtools
    * https://github.com/huhu/rust-search-extension
  */

  options.home.nix-polyglot = {
    enable = mkEnableOption "Enable nix-polyglot";
    langs = mkOption {
      type = with types; nullOr (listOf (enum languages));
      default = [ ];
      description = "List of languages to use.";
    };
    enableZshIntegration = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to enable Zsh integration.
      '';
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = polyglotPackages;
      example =
        literalExpression "with pkgs; [ git-ignore licensor just dotenv-linter ]";
      description = ''
        List of generic packages to install for development.
      '';
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = cfg.packages;
    };
  };
}

