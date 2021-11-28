{ config, options, lib, pkgs, ... }:

with lib;
with builtins;

let
  currLang = baseNameOf (builtins.toString ./.);
  enabled = elem currLang polyglot.langs || elem "all" polyglot.langs;
  polyglot = config.home.nix-polyglot;
  pLang = "home.nix-polyglot.lang.${currLang}";
  ifZsh = polyglot.enableZshIntegration;
  relToData = dir: if config.xdg.enable then "${config.xdg.dataHome}/${dir}" else "${homeDirectory}/.local/share/${dir}";
  GOPATH = (relToData "go");
  GOBIN = (relToData "go/bin");

  hasGoPath = hasAttrByPath ["GOPATH"] config.${pLang}.sessionVariables;
  hasGoBin  = hasAttrByPath ["GOBIN"] config.${pLang}.sessionVariables;
  canGoBin  = hasGoPath || hasGoBin;
  getGoPath = getAttrFromPath ["GOPATH"] config.${pLang}.sessionVariables;
  getGoBin  = getAttrFromPath ["GOBIN"]  config.${pLang}.sessionVariables;
  
  GoBin = if hasGoBin then
    getGoBin
  else
    "${getGoPath}/bin";

  imports = [
    ./vscode.nix
    #./neovim.nix
  ];

  langPackages = with pkgs; [
    go
    gopls
    gofumpt
    go-tools
    dep
  ];

  shellAliases = {
    gob = "go build";
    goc = "go clean";
    god = "go doc";
    gof = "go fmt";
    gofa = "go fmt ./...";
    gog = "go get";
    goi = "go install";
    gol = "go list";
    gom = "go mod";
    gop = "cd ${GOPATH}";
    gopb = "cd ${GOPATH}/bin";
    gops = "cd ${GOPATH}/src";
    gor = "go run";
    got = "go test";
    gov = "go vet";
  };

  langVars = {
    inherit GOBIN GOPATH;
    GO111MODULE = "auto";
  };

in
{
  inherit imports;
  options.${pLang} = {
    enable = mkOption {
      type = types.bool;
      default = enabled;
      description = "Whether to enable nix-polyglot's rust support.";
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = langPackages;
      description = ''
        List of packages to install for rust development.
      '';
    };
    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = shellAliases;
      description = ''
        An attribute set that maps aliases for ${currLang} programming.
      '';
    };
    sessionVariables = mkOption {
      type = types.attrs;
      default = langVars;
      example = { CCACHE_DIR = "$XDG_CACHE_HOME/ccache"; };
      description = ''
        Environment variables to always set at login for ${currLang} programming.
        </para><para>
      '';
    };
  };
  config = mkIf enabled {
    home = {
      packages = config.${pLang}.packages;
      sessionPath = mkIf canGoBin [ GoBin ];
      sessionVariables = config.${pLang}.sessionVariables;
    };
    programs.zsh.shellAliases = mkIf ifZsh config.${pLang}.shellAliases;
  };
}
