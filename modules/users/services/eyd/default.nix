{ config, lib, pkgs, ... }:

with lib;

let
    inherit (config.home) username;

    cfg = config.services.eyd;

    firefox-backup = (pkgs.writeShellScript "firefox-backup" ''
        ${pkgs.rsync}/bin/rsync -avh --exclude={'user.js','chrome','extensions','lock'} /home/${username}/.mozilla/firefox/${username} ${cfg.persistentPath}/home/${username}/.mozilla/firefox/
    '');

    chromium-backup = (pkgs.writeShellScript "chromium-backup" ''
        ${pkgs.rsync}/bin/rsync -avh  /home/${username}/.config/chromium ${cfg.persistentPath}/home/${username}/.config/chromium/
    '');

in {
    options = {
        services.eyd = {
            enable = mkEnableOption "Erase your darlings";

            persistentPath = mkOption {
                type = types.str;
                default = "";
                example = "/persist";
                description = "the path to persistent storage.";
            };

            firefox = mkOption {
                default = false;
                description = ''
                    Automatically sync firefox.
                '';
                type = types.bool;
            };

            chromium = mkOption {
                default = false;
                description = ''
                    Automatically sync chromium.
                '';
                type = types.bool;
            };

        };
    };

    config = mkIf cfg.enable {
        systemd.user = mkIf (cfg.firefox || cfg.chromium) {
            # This is effectively what psd does
            services = {
                firefox-persist = mkIf cfg.firefox {
                    Unit = {
                        Description = "Firefox persistent storage sync";
                        Before = "shutdown.target";
                    };

                    Service = {
                        CPUSchedulingPolicy = "idle";
                        IOSchedulingClass = "idle";
                        Environment = "PATH=${pkgs.coreutils}";
                        # copy all files except those that are symlinks
                        ExecStart = toString firefox-backup;
                    };
                };

                firefox-persist-pre-shutdown = mkIf cfg.firefox {
                    Unit = {
                        Description = "Firefox persistent storage sync before shutdown";
                    };

                    Service = {
                        Environment = "PATH=${pkgs.coreutils}";
                        # copy all files except those that are symlinks
                        ExecStart = toString firefox-backup;
                        TimeoutStartSec = 0;
                    };

                    Install = { WantedBy = [ "shutdown.target" ]; };
                };
                
                firefox-persist-login-logout = mkIf cfg.firefox {
                    Unit = {
                        Description = "Firefox persistent storage sync on login/logout";
                    };

                    Service = {
                        Type = "oneshot";
                        Environment = "PATH=${pkgs.coreutils}";
                        RemainAfterExit = true;
                        StandardOutput = "journal";
                        # copy all files except those that are symlinks
                        ExecStart = "${pkgs.coreutils}/bin/cp -r ${cfg.persistentPath}/home/${username}/.mozilla/firefox/${username} /home/${username}/.mozilla/firefox/";
                        ExecStop = toString firefox-backup;
                        TimeoutStartSec = 0;
                    };

                    Install = { WantedBy = [ "default.target" ]; };
                };
            };

            timers.firefox-persist = mkIf cfg.firefox {
                Unit = {
                    Description = "Firefox persistent storage periodic sync";
                };

                Timer = {
                    Unit = "firefox-persist.service";
                    # Run every 15 minutes
                    OnCalendar = "*:0/15";
                    Persistent = true;
                };

                Install = { WantedBy = [ "timers.target" ]; };
            };

            services = {
                chromium-persist = mkIf cfg.chromium {
                    Unit = {
                        Description = "Chromium persistent storage sync";
                        Before = "shutdown.target";
                    };

                    Service = {
                        CPUSchedulingPolicy = "idle";
                        IOSchedulingClass = "idle";
                        Environment = "PATH=${pkgs.coreutils}";
                        # copy all files except those that are symlinks
                        ExecStart = toString chromium-backup;
                    };
                };

                chromium-persist-pre-shutdown = mkIf cfg.chromium {
                    Unit = {
                        Description = "Chromium persistent storage sync before shutdown";
                    };

                    Service = {
                        Environment = "PATH=${pkgs.coreutils}";
                        # copy all files except those that are symlinks
                        ExecStart = toString chromium-backup;
                        TimeoutStartSec = 0;
                    };

                    Install = { WantedBy = [ "shutdown.target" ]; };
                };
                
                chromium-persist-login-logout = mkIf cfg.chromium {
                    Unit = {
                        Description = "Chromium persistent storage sync on login/logout";
                    };

                    Service = {
                        Type = "oneshot";
                        Environment = "PATH=${pkgs.coreutils}";
                        RemainAfterExit = true;
                        StandardOutput = "journal";
                        # copy all files except those that are symlinks
                        ExecStart = "${pkgs.coreutils}/bin/cp -r ${cfg.persistentPath}/home/${username}/.config/chromium /home/${username}/.config";
                        ExecStop = toString chromium-backup;
                        TimeoutStartSec = 0;
                    };

                    Install = { WantedBy = [ "default.target" ]; };
                };
            };

            timers.chromium-persist = mkIf cfg.chromium {
                Unit = {
                    Description = "Chromium persistent storage periodic sync";
                };

                Timer = {
                    Unit = "chromium-persist.service";
                    # Run every 15 minutes
                    OnCalendar = "*:0/15";
                    Persistent = true;
                };

                Install = { WantedBy = [ "timers.target" ]; };
            };
        };
    };
}