{ config, lib, pkgs, impermanence, ... }:
#sudo nixos-rebuild --flake .#nebula switch --show-trace 2>&1 | grep eyd -A 8 -B 1
let
    cfg = config.eyd;
    users = builtins.attrNames cfg.users;
    hasBlueTooth = config.hardware.bluetooth.enable;
    hasSystemdCoredump = config.systemd.coredump.enable;
    hasNetworkManager = config.networking.networkmanager.enable;
    hasConnMan = config.services.connman.enable;
    hasChrony = config.services.chrony.enable;
    hasPipeWire = config.services.pipewire.enable;
    hasSshGuard = config.services.sshguard.enable;
    hasHercules = config.services.hercules-ci-agent.enable;
    hasX11 = x_util: config.services.xserver.enable && lib.attrByPath (lib.splitString "." x_util) false config.services.xserver;
    hasKDE = hasX11 "desktopManager.plasma5.enable";
    hasSDDM = hasX11 "displayManager.sddm.enable";

    assertListStr = list: name:
    let
        wrong = builtins.filter (x: ! builtins.isString x) list;
    in
        if (builtins.length wrong < 1 ) then 
            true
        else
        lib.assertMsg "${name} should be a list of strings but contains ${lib.generators.toPretty {} wrong}" false;
        
    defaultDirectories = [
        (lib.optionalString (hasBlueTooth) "/var/lib/bluetooth")
        (lib.optionalString (hasSystemdCoredump) "/var/lib/systemd/coredump")
        (lib.optionalString (hasNetworkManager) "/etc/NetworkManager")
        (lib.optionalString (hasConnMan) "/var/lib/connman")
        (lib.optionalString (hasSshGuard) "/var/lib/sshguard")

        # services.chrony.directory defaults to "/var/lib/chrony"
        (lib.optionalString (hasChrony) "${config.services.chrony.directory}")

        (lib.optionalString (hasHercules) "/var/lib/hercules-ci-agent")
    ];

    defaultFiles = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/adjtime"
        "/etc/machine-id"
    ];

    defaultUserDirectories = user: 
    let

        hm = config.home-manager.users.${user};
        
	    home  = "/home/${user}";
        cache = hm.xdg.cacheHome;
        conf  = hm.xdg.configHome;
        data  = hm.xdg.dataHome;
        
	    desktop   = hm.xdg.userDirs.desktop;
        downloads = hm.xdg.userDirs.download;
        templates = hm.xdg.userDirs.templates;
        public    = hm.xdg.userDirs.publicShare;
        documents = hm.xdg.userDirs.documents;
        music     = hm.xdg.userDirs.music;
        pictures  = hm.xdg.userDirs.pictures;
        videos    = hm.xdg.userDirs.videos;

        hasPrg = prg: hm.programs.${prg}.enable;

        hasZsh = hm.programs.ZSH.enable;
        hasZshInteg = integ: hm.programs.ZSH.integrations.${integ}.enable;
        npg = hm.home.nix-polyglot;
        lang = lang: lib.attrByPath ["lang" "${lang}" "enable" ] false npg;

        hasGPG = hasPrg "gpg";
        hasDirEnv = hasPrg "direnv";
        gpgHomeDir = hm.programs.gpg.gpgHomeDir;


        vscodePname = npg.vscode.package.pname;
        vscodeConfigDir = {
            "vscode" = "Code";
            "vscode-insiders" = "Code - Insiders";
            "vscodium" = "VSCodium";
        }.${vscodePname};
        vscodeExtensionDir = {
            "vscode" = ".vscode";
            "vscode-insiders" = ".vscode-insiders";
            "vscodium" = ".vscode-oss";
        }.${vscodePname};
       

        in [
        "${cache}/fontconfig"
        "${cache}/gstreamer-1.0"
        "${cache}/lollypop"
        (lib.optionalString (hasPipeWire) "${conf}/pipewire/media-session.d")
        "${conf}/helix"
        "${data}/backgrounds"
        "${data}/icons"
        "${data}/keyrings"
        "${data}/lollypop"
        "${data}/nu"
        "${data}/themes"
        "${data}/Trash"
        "${desktop}"
        "${documents}"
        "${downloads}"
        "${music}"
        "${pictures}"
        #"${public}"
        #"${templates}"
        "${videos}"
        "${home}/.ssh"


        # DirEnv
        (lib.optionalString (hasDirEnv) "${data}/direnv")

        # GPG
        (lib.optionalString (hasGPG) "${gpgHomeDir}/private-keys-v1.d")
        (lib.optionalString (hasGPG) "${gpgHomeDir}/openpgp-revocs.d")

        # Nix Polyglot
        (lib.optionalString (lang "rust") "${data}/cargo")
        (lib.optionalString (lang "rust") "${data}/rustup")
        (lib.optionalString (lang "go")   "${data}/go")

        # Vscode
        (lib.optionalString (vscodePname != null) "${conf}/${vscodeConfigDir}")
        (lib.optionalString (vscodePname != null) "${cache}/mesa_shader_cache")
        (lib.optionalString (vscodePname != null) "${home}/.pki")
        (lib.optionalString (vscodePname != null) "${home}/${vscodeExtensionDir}")
        "${data}/vsliveshare"

        # Zsh
        (lib.optionalString (hasZsh ) "${cache}/zsh")
        (lib.optionalString (hasZsh ) "${data}/zsh")
        (lib.optionalString (hasZsh ) "${cache}/nix-index")
        (lib.optionalString (hasZsh ) "${cache}/starship")
        (lib.optionalString (hasZsh ) "${data}/zoxide")

        # KDE 
        (lib.optionalString (hasKDE ) "${data}/baloo")
        (lib.optionalString (hasKDE ) "${data}/kactivitymanagerd")
        (lib.optionalString (hasKDE ) "${data}/klipper")
        (lib.optionalString (hasKDE ) "${data}/konsole")
        (lib.optionalString (hasKDE ) "${data}/kwalletd")
        (lib.optionalString (hasKDE ) "${data}/kxmlgui5")
        (lib.optionalString (hasSDDM) "${data}/sddm")

        /**
        TODO: Figure out why this doesn't work
        (lib.optionalString (hasZsh && 
            hm.programs.ZSH.integrations.nix-index.enable) "$XDG_CACHE_HOME/nix-index")
        (lib.optionalString (hasZsh && 
            hm.programs.ZSH.integrations.starship.enable ) "$XDG_CACHE_HOME/starship")
        (lib.optionalString (hasZsh &&
           hm.programs.ZSH.integrations.zoxide.enable   ) "$XDG_DATA_HOME/zoxide")
         */
    ];


    defaultUserFiles  = user:
    assert builtins.isString user; 
    let
        hm = config.home-manager.users.${user};   

	    home  = "/home/${user}";
        cache = hm.xdg.cacheHome;
        conf  = hm.xdg.configHome;
        data  = hm.xdg.dataHome;

        hasPrg = prg: hm.programs.${prg}.enable;
        hasGPG = hasPrg "gpg";
        gpgHomeDir = hm.programs.gpg.gpgHomeDir;

    in [
        
        # GPG
        (lib.optionalString (hasGPG) "${gpgHomeDir}/trustdb.gpg")
        (lib.optionalString (hasGPG) "${gpgHomeDir}/pubring.kbx")

        # KDE
        (lib.optionalString (hasKDE ) "${conf}/akregatorrc")
        (lib.optionalString (hasKDE ) "${conf}/gwenviewrc")
        (lib.optionalString (hasKDE ) "${conf}/kactivitymanagerd-statsrc")
        (lib.optionalString (hasKDE ) "${conf}/kactivitymanagerdrc")
        (lib.optionalString (hasKDE ) "${conf}/kateschemarc")
        (lib.optionalString (hasKDE ) "${conf}/kcminputrc")
        (lib.optionalString (hasKDE ) "${conf}/kconf_updaterc")
        (lib.optionalString (hasKDE ) "${conf}/kded5rc")
        (lib.optionalString (hasKDE ) "${conf}/kglobalshortcutsrc")
        (lib.optionalString (hasKDE ) "${conf}/khotkeysrc")
        (lib.optionalString (hasKDE ) "${conf}/kmixrc")
        (lib.optionalString (hasKDE ) "${conf}/konsolerc")
        (lib.optionalString (hasKDE ) "${conf}/kscreenlockerrc")
        (lib.optionalString (hasKDE ) "${conf}/ksmserverrc")
        (lib.optionalString (hasKDE ) "${conf}/ktimezonedrc")
        (lib.optionalString (hasKDE ) "${conf}/kwinrc")
        (lib.optionalString (hasKDE ) "${conf}/kwinrulesrc")
        (lib.optionalString (hasKDE ) "${conf}/kxkbrc")
        (lib.optionalString (hasKDE ) "${conf}/okularpartrc")
        (lib.optionalString (hasKDE ) "${conf}/plasma-localerc")
        (lib.optionalString (hasKDE ) "${conf}/plasma-org.kde.plasma.desktop-appletsrc")
        (lib.optionalString (hasKDE ) "${conf}/plasmanotifyrc")
        (lib.optionalString (hasKDE ) "${conf}/plasmashellrc")
        (lib.optionalString (hasKDE ) "${conf}/powerdevilrc")
        (lib.optionalString (hasKDE ) "${conf}/powermanagementprofilesrc")
        (lib.optionalString (hasKDE ) "${conf}/spectaclerc")
        (lib.optionalString (hasKDE ) "${conf}/startkderc")
        (lib.optionalString (hasKDE ) "${conf}/systemsettingsrc")
        (lib.optionalString (hasKDE ) "${conf}/krunnerstaterc")
        (lib.optionalString (hasKDE ) "${conf}/recently-used.xbel")
        (lib.optionalString (hasKDE ) "${conf}/user-places.xbel")



    ];

    mkUserpaths = usr: path:
        assert builtins.isString usr;
        assert builtins.isString path;
        if (path == "" || builtins.substring 0 1 path  == "/" ) then
            path
        else if (builtins.substring 0 1 path  == "~" ) then
            builtins.replaceStrings ["~"] ["/home/${usr}"] path
        else 
            "/home/${usr}/${path}";


    nixDirectories = lib.remove "" (lib.unique (cfg.directories ++ (if cfg.enableDefaults then defaultDirectories else [])));
    nixFiles       = lib.remove "" (lib.unique (cfg.files       ++ (if cfg.enableDefaults then defaultFiles       else [])));
    
    userDirectories =
        let 
            userDefinedDirectories = 
                lib.flatten(lib.forEach users (user:
                    if lib.hasAttrByPath [ "${user}" "directories" ] cfg.users then
                        lib.forEach (cfg.users.${user}.directories) (dir: mkUserpaths user dir)
                    else
                        []
                ));
 
            userDefaultDirectories = 
                lib.flatten(lib.forEach users (user: 
                    if cfg.users.${user}.enableDefaults then 
                        defaultUserDirectories user
                    else []
                ));
        in lib.remove "" (lib.unique (userDefinedDirectories ++ userDefaultDirectories));

    userFiles =
        let 
            userDefinedFiles =
                lib.flatten(lib.forEach users (user:
                    if lib.hasAttrByPath [ "${user}" "files" ] cfg.users then
                        lib.forEach cfg.users.${user}.files (file: mkUserpaths user file)
                    else
                        []
                ));

            userDefaultFiles = 
                lib.flatten(lib.forEach users (user: 
                    if cfg.users.${user}.enableDefaults then 
                            defaultUserFiles user
                    else []
                ));
                
        in lib.remove "" (lib.unique (userDefinedFiles ++ userDefaultFiles));
    
    AllPersistentDirectories = lib.remove "" (lib.unique (nixDirectories ++ userDirectories));
    AllPersistentFiles       = lib.remove "" (lib.unique (nixFiles       ++ userFiles      ));

in 
{

    options = {
        eyd = {
            enable = lib.mkEnableOption "Erase you darlings";
            enableDefaults = lib.mkOption {
                type = lib.types.bool;
                default = true;
                example = false;
                description = "Enable default directories and files for system.";
            };

            persistentPath = lib.mkOption {
                type = lib.types.str;
                default = "";
                example = "/persist";
                description = "the path to persistent storage.";
            };

            files = lib.mkOption {
                type = with lib.types; listOf str;
                default = [ ];
                example = [
                  "/etc/machine-id"
                  "/etc/nix/id_rsa"
                ];
                description = ''
                  Files in /etc that should be stored in persistent storage.
                '';
              };

            directories = lib.mkOption {
                type = with lib.types; listOf str;
                default = [ ];
                example = [
                  "/var/log"
                  "/var/lib/bluetooth"
                  "/var/lib/systemd/coredump"
                  "/etc/NetworkManager/system-connections"
                ];
                description = ''
                  Directories to bind mount to persistent storage.
                '';
            };

            users = lib.mkOption {
                default = { };
                type = with lib.types; attrsOf (submodule {
                    options = {
                        enableDefaults = lib.mkOption {
                            type = lib.types.bool;
                            default = true;
                            example = false;
                            description = "Enable default directories and files for user.";
                        };
                        directories = lib.mkOption {
                            type = with lib.types; listOf str;
                            default = [ ];
                            example = [
                                "Downloads"
                                "Music"
                                "Pictures"
                                "Documents"
                                "Videos"
                                "VirtualBox VMs"
                                ".gnupg"
                                ".ssh"
                                ".local/share/keyrings"
                                ".local/share/direnv"
                            ];
                            description = ''
                                A list of directories in your home directory that
                                you want to link to persistent storage.
                            '';
                        };

                        files = lib.mkOption {
                            type = with lib.types; listOf str;
                            default = [ ];
                            example = [
                                ".screenrc"
                            ];
                            description = ''
                                A list of files in your home directory you want to
                                link to persistent storage.
                            '';
                        };
                    };
                });
                description = ''
                    user name
                '';
            };
        };
    };

    config = lib.mkIf (cfg.enable && cfg.persistentPath != "") {
        environment =  {
            persistence.${cfg.persistentPath} = {
                directories = lib.mkAfter AllPersistentDirectories;
                files = lib.mkAfter AllPersistentFiles;
            };
            
            etc = {
                nixos.source = "${cfg.persistentPath}/etc/nixos";
                NIXOS.source = "${cfg.persistentPath}/etc/NIXOS";
            };
        };
       
        services = {
            plex = lib.mkIf (config.services.plex.enable) {
                dataDir = "${cfg.persistentPath}/var/lib/plex";
            };
            Jellyfin = lib.mkIf (config.services.Jellyfin.enable) {
                cacheDir = "${cfg.persistentPath}/var/cache/jellyfin";
                dataDir = "${cfg.persistentPath}/var/lib/jellyfin";
            };
        };
        users.mutableUsers = false;
    };
}

