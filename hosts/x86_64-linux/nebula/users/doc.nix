{ lib, config, pkgs, home-manager, ... }:

let 
  user = "doc";
  homey = config.home-manager.users.${user}.home.homeDirectory;

  zoomUsFixed = pkgs.zoom-us.overrideAttrs (old: {
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/zoom-us --unset XDG_SESSION_TYPE
      '';});
    zoom = pkgs.zoom-us.overrideAttrs (old: {
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/zoom --unset XDG_SESSION_TYPE
      '';});


  passwd = (lib.concatMapStrings (x: x + "/") (lib.sublist 4 3 (lib.splitString "/" (builtins.toString ./.)))) + "secrets/${user}.age";

in {
  imports = [
    (lib.mkAliasOptionModule [ "${user}" ] [ "home-manager" "users" "${user}" ])
  ];
  age.secrets.${passwd} = {
    file = ../secrets + "/${user}.age";
    #path = "/run/agenix/keys/${user}";
    };
  users.users.${user} = {
    uid = 1000;
    description = "Just the doctor";
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "users"
      "wheel"
      "input"
      "networkmanager"
      "libvirtd"
      "adbusers"
      "video"
      "media"
      "i2c"
      (lib.optionalString config.virtualisation.docker.enable "docker")
      (lib.optionalString config.virtualisation.podman.enable "podman")
    ];
    passwordFile = config.age.secrets.${passwd}.path;

    packages = with pkgs; [
      git-lfs
      git
      git-subrepo
      delta
      gitoxide
      lazygit
      gitui
      firefox-wayland
      
      #vscodium
      transmission
      transmission-gtk
      #transmission-qt
      lollypop
      zellij
      #helix
      

      #handbrake
      #gnome_mplayer
      mpv


      #anime4kcpp
      #dim
    ] ++ [zoom zoomUsFixed];
  };


  ${user} = { lib, ... }: {
   
    home = { stateVersion = "21.05"; };

    imports = [
      ../desktop/gnome.nix
    ];

    programs = {
      git = {
        userName = "Th3Whit3Wolf";
        userEmail = "the.white.wolf.is.1337@gmail.com";
      };
    };

    services = {
      eyd = {
        enable = true;
        persistentPath = "/persist";
      };
    };

    systemd.user.startServices = "sd-switch";

    xdg = {
      enable = true;
      cacheHome  = lib.mkBefore "/home/doc/.cache";
      configHome = lib.mkBefore "/home/doc/.config";
      dataHome   = lib.mkBefore "/home/doc/.local/share";
      userDirs = {
        enable = true;
        desktop = lib.mkBefore "/home/doc/Desk";
        documents = lib.mkBefore "/home/doc/Docs";
        download = lib.mkBefore "/home/doc/Downs";
        music = lib.mkBefore "/home/doc/Tunes";
        pictures = lib.mkBefore "/home/doc/Pics";
        publicShare = lib.mkBefore "/home/doc/Public";
        templates = lib.mkBefore "/home/doc/Templates";
        videos = lib.mkBefore "/home/doc/Vids";
        extraConfig = {
          XDG_CODE_HOME = "/home/doc/Code";
          XDG_GIT_HOME = "/home/doc/Gits";
          XDG_BIN_HOME = "/home/doc/.local/bin";
        };
      };
    };
  };
}
