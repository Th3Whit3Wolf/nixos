{ config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
in
{
  home = {
    packages = [ pkgs.nerdfonts ];
    file.".vscode/extensions/ms-vsliveshare.vsliveshare-1.0.5090" = {
      source = pkgs.vscode-extensions.ms-vsliveshare.vsliveshare;
    };
    nix-polyglot = {
      enable = true;
      langs = lib.mkForce [ "all" ];
      enableZshIntegration = false;
      neovim.enable = true;
      vscode = {
        enable = true;
        userSettings = {
          editor = {
            fontFamily =
              "'JetBrainsMono Nerd Font Mono', monospace, 'Droid Sans Fallback'";
            fontLigatures = true;
            inlayHints.fontFamily =
              "'VictorMono Nerd Font Mono', monospace, 'Droid Sans Fallback'";
          };
          extensions = {
            autoCheckUpdates = false;
            autoUpdate = false;
          };
          window.menuBarVisibility = "toggle";
          workbench = {
            colorTheme = "Spacemacs - dark";
            iconTheme = "material-icon-theme";
          };
          update = {
            mode = "none";
            showReleaseNotes = false;
          };
          telemetry = {
            enableTelemetry = false;
            enableCrashReporter = false;
          };
        };
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
