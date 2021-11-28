{ config, lib, pkgs, ... }:
with lib;
with builtins;
let
  currLang = baseNameOf (builtins.toString ./.);
  polyglot = config.home.nix-polyglot;
  cfg = polyglot.lang.${currLang};
  enabled = (elem currLang polyglot.langs || elem "all" polyglot.langs) && polyglot.neovim.enable;

  plugins = mkOption {
    type = with types; listOf (either package pluginWithConfigType);
    default = with pkgs.vimPlugins; [
      {
        plugin = rust-vim;
        optional = true;
      }
      {
        plugin = vim-crates;
        optional = true;
      }
      {
        plugin = vim-cargo-make;
        optional = true;
      }
      {
        plugin = vim-duckscript;
        optional = true;
      }
    ];
  };

in
{
  options.home.nix-polyglot.lang.${currLang}.neovim = {
    plugins = mkOption {
      type = with types; listOf (either package pluginWithConfigType);
      default = [ ];
      example = literalExpression ''
        with pkgs.vimPlugins; [
            yankring
            vim-nix
            { plugin = vim-startify;
            config = "let g:startify_change_to_vcs_root = 0";
            }
        ]
      '';
      description = ''
        List of neovim plugins to be used for ${currLang} programming.
      '';
    };
  };
}
