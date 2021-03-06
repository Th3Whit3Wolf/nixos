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
          ".cache/gsconnect"
          ".config/gsconnect"
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
    #chromium
    handbrake
    nodePackages.live-server
    marktext
    ragenix

    helix
  ];

  prg.chromium.enable = true;  
  programs.noisetorch.enable = true;

  harden.kernel.enable = true;
  system = {
    enable = true;
    kind = "laptop";
    cpu = "amd";
    gpu = "amd";
    ssdBoot = true;
    backlightName = "amdgpu_bl0";
    keyboardName = "asus::kbd_backlight";
    #externMonitorName = "12c12";
    laptopManufacturer = "asus";
    laptopModel = "ZenBook_UM425IA";
    laptopBatteryChargeThreshold = 60;
  };
  
  age.identityPaths = [
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
  users.groups.i2c = { };
  users.users = { 
    root = { 
      initialPassword = "test";
      #passwordFile = config.age.secrets.${passwd}.path; 
    }; 
  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It???s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
