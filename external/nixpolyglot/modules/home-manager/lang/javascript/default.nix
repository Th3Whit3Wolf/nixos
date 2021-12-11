{ config, options, lib, pkgs, ... }:

with lib;
with builtins;

let
  currLang = baseNameOf (builtins.toString ./.);
  enabled = elem currLang polyglot.langs || elem "all" polyglot.langs;
  polyglot = config.home.nix-polyglot;
  pLang = "home.nix-polyglot.lang.${currLang}";
  ifZsh = polyglot.enableZshIntegration;

  imports = [
    ./vscode.nix
    #./neovim.nix
  ];

  langPackages = with pkgs; [
    #nodejs
    nodejs-16_x
    nodePackages.node2nix
    yarn2nix
    yarn
    #nodePackages.npm
    deno
    #nodePackages.purescript-language-server
    nodePackages.typescript-language-server
    nodePackages.typescript
    #elmPackages.elm-language-server
    #nodePackages.vue-language-server
    #nodePackages.javascript-typescript-langserver
    nodePackages.eslint
    nodePackages.prettier

    # Task Runners
    #nodePackages.grunt-cli
    #nodePackages.gulp
    #nodePackages.jake

    # Bundlers
    #nodePackages.webpack
    #nodePackages.browserify
    #nodePackages.rollup
    #nodePackages.parcel-bundler

    #SWC

    # Node Version Manager
    #fnm

    #postman
  ];

  shellAliases = {
    n = "npm";
    y = "yarn";
    ya = "yarn add";
    yad = "yarn add --dev";
    yap = "yarn add --peer";
    yb = "yarn build";
    ycc = "yarn cache clean";
    yga = "yarn global add";
    ygls = "yarn global list";
    ygrm = "yarn global remove";
    ygu = "yarn global upgrade";
    yh = "yarn help";
    yi = "yarn init";
    yin = "yarn install";
    yls = "yarn list";
    yout = "yarn outdated";
    yp = "yarn pack";
    yrm = "yarn remove";
    yrun = "yarn run";
    ys = "yarn serve";
    yst = "yarn start";
    yt = "yarn test";
    yuc = "yarn global upgrade && yarn cache clean";
    yui = "yarn upgrade-interactive";
    yup = "yarn upgrade";
  };

  langVars = {
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    #NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
    NPM_CONFIG_PREFIX = "${config.xdg.cacheHome}/npm";
    NODE_REPL_HISTORY = "${config.xdg.cacheHome}/node/repl_history";
    NVM_DIR = "${config.xdg.dataHome}/nvm";
  };
in
{
  inherit imports;
  options.${pLang} = {
    enable = mkOption {
      type = types.bool;
      default = enabled;
      description = "Whether to enable nix-polyglot's ${currLang} support.";
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = langPackages;
      description = ''
        List of packages to install for ${currLang} development.
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
      example = { CCACHE_DIR = "${config.xdg.cacheHome}/ccache"; };
      description = ''
        Environment variables to always set at login for ${currLang} programming.
        </para><para>
      '';
    };
  };
  config = mkIf enabled {
    home = {
      packages = config.${pLang}.packages;
      sessionVariables = config.${pLang}.sessionVariables;
    };
    programs.zsh = {
      shellAliases = mkIf ifZsh config.${pLang}.shellAliases;
    };
    xdg.configFile."npm/config".text = ''
      cache=''${XDG_CACHE_HOME}/npm
      prefix=''${XDG_DATA_HOME}/npm
      tmp=''${XDG_RUNTIME_DIR}/npm
      init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
    '';
  };
}

/* tmp=$XDG_RUNTIME_DIR/npm */
