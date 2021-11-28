{ config, lib, pkgs, fetchzip, ... }:

with lib;

let
  cfg = config.networking.vpn.pia;
  enabled = cfg.enable && config.networking.vpn.enable;
  inherit (pkgs) openvpn;
  resolver = if  config.services.resolved.enable then pkgs.update-systemd-resolved else pkgs.update-resolv-conf;
  mkOpenVPNJob = import ../mkOpenVPNJob.nix {inherit config lib pkgs resolver;}; 

  resources = {
    recommended = pkgs.fetchzip {
      name = "pia-vpn-config";
      url = "https://www.privateinternetaccess.com/openvpn/openvpn.zip";
      sha256 = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
      stripRoot = false;
    };  
    strong = pkgs.fetchzip {
      name = "pia-vpn-config";
      url = "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip";
      sha256 = "/zaZvrRz2+vqBxV3E35qhinmp4rxdFUfpLOXH3merao=";
      stripRoot = false;
    };
    strongTcp = pkgs.fetchzip {
      name = "pia-vpn-config";
      url = "https://www.privateinternetaccess.com/openvpn/openvpn-strong-tcp.zip";
      sha256 = "/zaZvrRz2+vqBxV3E35qhinmp4rxdFUfpLOXH3merao=";
      stristripRoot = false;
    };
    ip = pkgs.fetchzip {
      name = "pia-vpn-config";
      url = "https://www.privateinternetaccess.com/openvpn/openvpn-ip.zip";
      sha256 = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
      stripRoot = false;
    };
    tcp = pkgs.fetchzip {
      name = "pia-vpn-config";
      url = "https://www.privateinternetaccess.com/openvpn/openvpn-tcp.zip";
      sha256 = "ZA8RS6eIjMVQfBt+9hYyhaq8LByy5oJaO9Ed+x8KtW8=";
      stripRoot = false;
    };
  };

  piaVPNSettings = 
    let
      inherit resources;
      servers = map (builtins.replaceStrings [ ".ovpn" "_" ] [ "" "-" ])
        (builtins.filter (name: !(isNull (builtins.match ".+ovpn$" name)))
        (builtins.attrNames (builtins.readDir resources.${cfg.openVPNConfiguration})));
      make_server = (name: {
        name = "pia-${name}";
        value = {
          autoStart = false;
          config = "config ${resources.${cfg.openVPNConfiguration}}/${builtins.replaceStrings [ "-" ] [ "_" ] name}.ovpn";
          extraConfig = {
            auth-user-pass = cfg.authUserPass;
          };
          updateResolvConf = true;
          up = "";
          down = "";
        };
      });
    in listToAttrs (map make_server servers);

in
{
  options = {
    networking.vpn.pia = {
      enable = mkEnableOption "Erase you darlings";
      openVPNConfiguration  = mkOption {
        default = "recommended";
        description = ''
            Possible pia OpenVPN configurations
        '';
        type = types.enum (builtins.attrNames resources);
      };
      authUserPass = mkOption {
        default = false;
        description = ''
            Path to file containing 
                pia username on the first line
                pia password on the secobd line
        '';
        type = types.str;
      };
    };
  };
  config = mkIf enabled {
    environment.systemPackages = [ openvpn ];
    boot.kernelModules = [ "tun" ];
    systemd.services = mkOpenVPNJob piaVPNSettings;
  };
}

/*
 * TODO
 * Set up Internet "kill swith" as mention https://wiki.archlinux.org/title/Private_Internet_Access#Internet_%22kill_switch%22
 * Set up network manager dispatcher script ot prevent DNS leaks mentioned https://wiki.archlinux.org/title/Private_Internet_Access/AUR#DNS_Leaks
*/