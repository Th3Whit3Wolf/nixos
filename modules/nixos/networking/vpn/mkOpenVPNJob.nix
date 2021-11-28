{config, lib, pkgs, resolver}:
with lib;

vpnAttr:
let

mkOpenVPNJob' = cfg: name:
    let

      path = makeBinPath (getAttr "openvpn-${name}" config.systemd.services).path;

      upScript = ''
        #! /bin/sh
        export PATH=${path}
        # For convenience in client scripts, extract the remote domain
        # name and name server.
        for var in ''${!foreign_option_*}; do
          x=(''${!var})
          if [ "''${x[0]}" = dhcp-option ]; then
            if [ "''${x[1]}" = DOMAIN ]; then domain="''${x[2]}"
            elif [ "''${x[1]}" = DNS ]; then nameserver="''${x[2]}"
            fi
          fi
        done
        ${cfg.up}
        ${optionalString cfg.updateResolvConf
          (if resolver == pkgs.update-systemd-resolved then
           "${resolver}/libexec/openvpn/update-systemd-resolved"
           else
           "${resolver}/libexec/openvpn/update-resolv-conf"
           )}
      '';

      downScript = ''
        #! /bin/sh
        export PATH=${path}
        ${optionalString cfg.updateResolvConf
          (if resolver == pkgs.update-systemd-resolved then
           "${resolver}/libexec/openvpn/update-systemd-resolved"
           else
           "${resolver}/libexec/openvpn/update-resolv-conf"
           )}
        ${cfg.down}
      '';

      configFile = pkgs.writeText "openvpn-config-${name}"
        ''
          errors-to-stderr
          ${optionalString (cfg.up != "" || cfg.down != "" || cfg.updateResolvConf) "script-security 2"}
          ${cfg.config}
          ${optionalString (cfg.up != "" || cfg.updateResolvConf)
              "up ${pkgs.writeScript "openvpn-${name}-up" upScript}"}
          ${optionalString (cfg.down != "" || cfg.updateResolvConf)
              ''down ${pkgs.writeScript "openvpn-${name}-down" downScript}
              ${optionalString (resolver == pkgs.update-systemd-resolved && cfg.updateResolvConf) "down-pre"}''}
          ${optionalString (cfg.extraConfig != null && cfg.extraConfig != {} && builtins.isAttrs cfg.extraConfig)
          "${concatStringsSep "\n" (mapAttrsToList (n: v: n + " " + v) cfg.extraConfig)}"}
        '';

    in {
        description = "OpenVPN instance ‘${name}’";

        wantedBy = optional cfg.autoStart "multi-user.target";
        after = [ "network.target" ];

        path = [ pkgs.iptables pkgs.iproute2 pkgs.nettools ];

        serviceConfig.ExecStart = "@${pkgs.openvpn}/sbin/openvpn openvpn --suppress-timestamps --config ${configFile}";
        serviceConfig.Restart = "always";
        serviceConfig.Type = "notify";
    };
in listToAttrs (mapAttrsFlatten (name: value: nameValuePair "openvpn-${name}" (mkOpenVPNJob' value name)) vpnAttr)