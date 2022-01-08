{ config, pkgs, unstable, ... }: {
  nixpkgs.config.allowBroken = true;
  services = {
    openssh.enable = true;
    irqbalance.enable = true;
    plex = {
      enable = true;
      openFirewall = true;
    };
    Jellyfin = { 
      enable = true;
      openFirewall = true;
    };
    fwupd.enable = true;
  };
}