{ config, lib, pkgs, ... }:

with lib;

let
    inherit (config.home) username;

    cfg = config.services.eyd;

    firefox-backup = (pkgs.writeShellScript "firefox-backup" ''
        ${pkgs.rsync}/bin/rsync -avh --exclude={'user.js','chrome','extensions','lock'} /home/${username}/.mozilla/firefox/${username} ${cfg.persistentPath}/home/${username}/.mozilla/firefox/
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
        };
    };

    config = mkIf cfg.enable {
        systemd.user = mkIf (cfg.firefox) {
            # This is effectively what psd does
            services = {
                firefox-persist = {
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

                firefox-persist-pre-shutdown = {
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
                
                firefox-persist-login-logout = {
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

            timers.firefox-persist = {
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
        };
    };
}