{ config, lib, pkgs, ... }: 

let
  persistentPath = "/persist";
  passwd = (lib.concatMapStrings (x: x + "/") (lib.sublist 3 3 (lib.splitString "/" (builtins.toString ./.)))) + "secrets/root.age";
  secrets = (import ../../../../secrets).allSystems.${config.networking.hostname};
  userSSHKeys = lib.mapAttrsToList (n: v: "${persistentPath}/home/${builtins.elemAt (lib.splitString "." n) 0}/.ssh/id_ed25519") 
    (lib.filterAttrs (filename: filetype: filename != "root.age" && filetype == "regular") 
    (builtins.readDir ./secrets));
in {
  # Set your time zone.
  time.timeZone = "America/Denver";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  sound.enable = true;

  imports = [ ./services.nix ./networking.nix ./hardware.nix ./virtualization.nix ./users/doc.nix ];
  
  # Steam
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-runtime"
      "virtualboxExtpack"
    ];
    packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        nativeOnly = true;
      };
    };
  };

  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
    ] ++ userSSHKeys;
    secrets.${passwd} = {
      file = ./secrets/root.age;
      #path = "/run/agenix/keys/${user}";
    };
  };



  hardware = {
    pulseaudio.enable = true;
    enableAllFirmware = true;
  };

  environment.systemPackages = with pkgs; [
    fup-repl
    ddcutil
    openrgb
    neovim
    wget
    firefox-wayland
    vscode
    libappindicator-gtk3
    libdbusmenu
    libsForQt5.libdbusmenu
    libdbusmenu-gtk3
    chromium
    handbrake
    nodePackages.live-server
    marktext
    ragenix
  ];

  eyd = {
    enable = true;
    inherit persistentPath;
    
    users."doc" = {
      directories = [
        ".cache/gsconnect"
        ".config/gsconnect"
        ".config/chromium"
        ".local/bin"
        "Code"
        "Gits"
        "KVM"
      ];

      files = [
        ".config/zoomus.conf"
      ];
    };
  };

  harden.kernel.enable = true;

  programs = {
    noisetorch.enable = true;
    steam.enable = true;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  system = {
    enable = true;
    kind = "desktop";
    cpu = "amd";
    gpu = "amd";
    externMonitorName = "i2c3";
  };

  users = {
    groups = {
      media = { };
      i2c = { };
    };
    users = { 
      root = { 
        passwordFile = config.age.secrets.${passwd}.path; 
      }; 
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
