{ config, lib, pkgs, ... }: 

let
  persistentPath = "/persist";
  passwd = (lib.concatMapStrings (x: x + "/") (lib.sublist 3 3 (lib.splitString "/" (builtins.toString ./.)))) + "secrets/root.age";
  secrets = (import ../../../../secrets).allSystems.${config.networking.hostname};
  userSSHKeys = lib.mapAttrsToList (n: v: "${persistentPath}/home/${builtins.elemAt (lib.splitString "." n) 0}/.ssh/id_ed25519") 
    (lib.filterAttrs (filename: filetype: filename != "root.age" && filetype == "regular") 
    (builtins.readDir ./secrets));
in {
  
  imports = [ ./services.nix ./networking.nix ./hardware.nix ./users/doc.nix ];

  # Set your time zone.
  time.timeZone = "Europe/London";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  eyd = {
      enable = true;
      inherit persistentPath;
      
      users."doc" = {
        directories = [ 
          "Code"
          "Gits"
          ".local/bin"
          "KVM"
        ];

        files = [
        ];
      };
    };

  environment.systemPackages = with pkgs; [
    fup-repl
    ddcutil
    neovim
    wget
    firefox-wayland
    konsole
    kde-gtk-config
    #oxygen-gtk
    vscodium
    vscode
    libappindicator-gtk3
    libdbusmenu
    libsForQt5.libdbusmenu
    libdbusmenu-gtk3
    nodejs
    docker

    mesa
  ];

  harden.kernel.enable = true;
  system = {
    enable = true;
    kind = "desktop";
    cpu = "amd";
    gpu = "amd";
  };
  
  age.sshKeyPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ] ++ userSSHKeys;

  # this is needed to get a bridge with DHCP enabled
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

age.secrets.${passwd} = {
    file = ./secrets/root.age;
    #path = "/run/agenix/keys/${user}";
    };
  users.groups.media = { };
  users.users = { root = { passwordFile = config.age.secrets.${passwd}.path; }; };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
