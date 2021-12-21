{ config, lib, pkgs, modulesPath, ... }:

let 
  fsOptBase = ["noatime" "nodev" "nosuid"];
  btrfsOpts = [
    "ssd"
    "compress=zstd"
    "space_cache=v2"
    "discard=async"
    "autodefrag"
  ];
in  {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      availableKernelModules = [
        "aesni_intel"
        "cryptd"
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "uas"
        "usbhid"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "asus-nb-wmi"
        "i2c-dev"
        "i2c-piix4"
      ];

      luks.devices = {
        "crypt" = {
          device = "/dev/disk/by-uuid/57d2784d-0fcb-471b-838f-cbcca73fda93";
          allowDiscards = true;
          #reusePassphrases = true;
        };

      };
    };

    kernelParams = [
      # Give interactive shell option on boot faile
      "boot.shell_on_fail"
      
    ];
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq_pie";
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 20;
        enable = true;
      };
    };
    #supportedFilesystems = [ "ntfs" ];
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = fsOptBase ++
        [ "defaults" "size=4G" "mode=755" "noexec" ];
    };

    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      # Note: insufficient size may cause nixos-rebuild to fail (nixos builds on /tmp)
      options = fsOptBase ++ [ "defaults" "size=8G" "mode=755" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/1A6A-41C8";
      fsType = "vfat";
      options = fsOptBase ++ [ "noexec" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/55e7ba18-7d5d-41b5-9c11-3de4cfda1b7a";
      fsType = "btrfs";
      options = ["subvol=@nix"] ++ fsOptBase ++ btrfsOpts;
      neededForBoot = true;
    };

    "/persist" = {
      device = "/dev/disk/by-uuid/55e7ba18-7d5d-41b5-9c11-3de4cfda1b7a";
      fsType = "btrfs";
      options = ["subvol=@persist"] ++ fsOptBase ++ btrfsOpts;
      neededForBoot = true;
    };

    "/var/log" = {
      device = "/dev/disk/by-uuid/55e7ba18-7d5d-41b5-9c11-3de4cfda1b7a";
      fsType = "btrfs";
      options = ["subvol=@log"] ++ fsOptBase ++ btrfsOpts;
      neededForBoot = true;
    };

  };

  hardware.video.hidpi.enable = lib.mkDefault true;
}
