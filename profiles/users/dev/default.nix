{ config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
in
{
  home = {
    nix-polyglot = {
      enable = true;
      langs = [ "all" ];
      enableZshIntegration = false;
      neovim.enable = true;
      vscode = {
        enable = true;
        #package = pkgs.vscode;
      };
    };
    sessionVariables = {
      HELIX_RUNTIME = "${homeDirectory}/.config/helix/runtime";
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
  services.lorri.enable = true;
  systemd.user.sessionVariables = {
    HELIX_RUNTIME = "${homeDirectory}/.config/helix/runtime";
  };
}
