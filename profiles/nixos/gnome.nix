{ config, pkgs, unstable, ... }: 
let 
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    tweaks-in-system-menu
    blur-me
    blur-my-shell
    just-perfection
    gnome-40-ui-improvements
    user-themes
    big-sur-status-area
    brightness-control-using-ddcutil
    tray-icons-reloaded
    dash-to-dock
    timepp
  ];

  gnomePackages = with pkgs.gnome; [
    adwaita-icon-theme
    gnome-tweaks
    pomodoro
  ];
  
in {
  config = {
    environment.systemPackages = with pkgs; [
      dconf2nix
    ] ++ gnomePackages ++ extensions;
    programs = {
      dconf.enable = true;
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    # gdm wont find user if `users.users.<user>.shell = pkgs.zsh;` and this isn't set
      zsh.enable = true;
    };
    services = {
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
        gnome-initial-setup.enable = false;
      };
      xserver = {
        enable = true;
        displayManager.gdm = {
          enable = true;
          #wayland = true;
          #debug = true;
        };  
        desktopManager.gnome.enable = true;
        libinput.enable = true;
      };
      udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
    };
    security.pam.services.gdm.enableGnomeKeyring = true;
  };
}

