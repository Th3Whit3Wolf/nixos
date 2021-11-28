{ config, lib, ... }:
let
    cfg = config.harden.networkmanager;
in
{
  options = {
    harden.networkmanager = {
      enable = lib.mkEnableOption "Enable hardening of NetworkManager.service";
    };
  };
  config = lib.mkIf (cfg.enable && config.networking.networkmanager.enable) {
    systemd.services = {
      NetworkManager.serviceConfig = {
        /*
          * Networking
        */

        # PrivateNetwork= service needs access to host network
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_PACKET AF_UNIX";
        # IPAccounting = "yes";
        # IPAddressAllow = "any";
        # IPAddressDeny= service needs access to all IPs

        /*
          * File system
        */

        #  Note that the effect of these settings may be undone by privileged processes. In order to
        #  set up an effective sandboxed environment for a unit it is thus recommended to combine
        #  these settings with either CapabilityBoundingSet=~CAP_SYS_ADMIN or
        #  SystemCallFilter=~@mount.

        ProtectHome = "yes";
        ProtectSystem = "full";
        ProtectProc = "ptraceable";
        ReadWritePaths = "/etc/resolv.conf /etc/machine-id -/etc/NetworkManager -/proc/sys/net -/run/resolvconf -/var/lib/NetworkManager -/var/run/NetworkManager";
        PrivateTmp = "yes";

        /*
          * User separation
        */

        # PrivateUsers= service runs as root
        # DynamicUser= service runs as root

        /*
          * Devices
        */

        PrivateDevices = "yes";
        # DeviceAllow=/dev/exampledevice

        /*
          * Kernel
        */

        ProtectKernelTunables = "yes";
        ProtectKernelModules = "yes";
        ProtectKernelLogs = "yes";

        /*
          * Misc
        */

        UMask = "077";
        CapabilityBoundingSet = "~CAP_SYS_ADMIN CAP_SETUID CAP_SETGID CAP_SYS_CHROOT";
        # AmbientCapabilities= service runs as root
        NoNewPrivileges = "yes";
        ProtectHostname = "yes";
        ProtectClock = "yes";
        ProtectControlGroups = "yes";
        RestrictNamespaces = "yes";
        LockPersonality = "yes";
        MemoryDenyWriteExecute = "yes";
        RestrictRealtime = "yes";
        RestrictSUIDSGID = "yes";
        # RemoveIPC= service runs as root

        /*
          * System calls
        */

        #SystemCallFilter = [
        #  "@system-service"
        #  "~@resources @privileged"
        #];

        SystemCallArchitectures = "native";

      };
      NetworkManager-dispatcher.serviceConfig = {
        /*
          * Networking
        */

        # PrivateNetwork= service needs access to host network
        #RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_PACKET AF_UNIX";
        # IPAccounting = "yes";
        # IPAddressAllow = "any";
        # IPAddressDeny= service needs access to all IPs

        /*
          * File system
        */

        #  Note that the effect of these settings may be undone by privileged processes. In order to
        #  set up an effective sandboxed environment for a unit it is thus recommended to combine
        #  these settings with either CapabilityBoundingSet=~CAP_SYS_ADMIN or
        #  SystemCallFilter=~@mount.

        ProtectHome = "yes";
        ProtectSystem = "full";
        ProtectProc = "ptraceable";
        ReadWritePaths = "-/etc/NetworkManager/dispatcher.d";
        PrivateTmp = "yes";

        #BindReadOnlyPaths = [
        #  "/nix/store"
        #];

        /*
          * User separation
        */

        # PrivateUsers= service runs as root
        # DynamicUser= service runs as root

        /*
          * Devices
        */

        PrivateDevices = "yes";
        # DeviceAllow=/dev/exampledevice

        /*
          * Kernel
        */

        ProtectKernelTunables = "yes";
        ProtectKernelModules = "yes";
        ProtectKernelLogs = "yes";

        /*
          * Misc
        */

        UMask = "077";
        CapabilityBoundingSet = "~CAP_SYS_ADMIN CAP_SETUID CAP_SETGID CAP_SYS_CHROOT";
        # AmbientCapabilities= service runs as root
        NoNewPrivileges = "yes";
        ProtectHostname = "yes";
        #ProtectClock = "yes";
        ProtectControlGroups = "yes";
        RestrictNamespaces = "yes";
        #LockPersonality = "yes";
        MemoryDenyWriteExecute = "yes";
        RestrictRealtime = "yes";
        RestrictSUIDSGID = "yes";
        RemainAfterExit = "yes";
        # RemoveIPC= service runs as root

        /*
          * System calls
        */

        #SystemCallFilter = [
        #  "@system-service"
        #  "~@resources @privileged"
        #];

        SystemCallArchitectures = "native";

      };
    };
  };
}

# https://madaidans-insecurities.github.io/guides/linux-hardening.html#ipv6-networkmanager
