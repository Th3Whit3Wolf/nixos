{ config, pkgs, unstable, ... }: {
config = {
  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
    gnomeExtensions.appindicator 
  ];
  programs.dconf.enable = true;
  # gdm wont find user if `users.users.<user>.shell = pkgs.zsh;` and this isn't set
  programs.zsh.enable = true;
  services = {
    gnome = {
      gnome-keyring.enable = true;
      sushi.enable = true;
    };
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
	wayland = true;
	debug = true;
      };  
      desktopManager.gnome.enable = true;
      libinput.enable = true;
    };
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
  security.pam.services.gdm.enableGnomeKeyring = true;
};
}

/*

ICEAutFile
unable to open named profile (/dconf/user)
Warning IceLockAuthFile failed: Permission denied
*/
