{ config, lib, pkgs, modulesPath, ... }:

let 
  fsOptBase = ["noatime" "nodev" "nosuid"];
  f2fsOpt = [
    "background_gc=on"
    "discard"
    "no_heap"
    "user_xattr"
    "inline_xattr"
    "acl"
    "inline_data"
    "inline_dentry"
    "flush_merge"
    "extent_cache"
    "mode=adaptive"
    "active_logs=6"
    "alloc_mode=default"
    "fsync_mode=posix"
    "checkpoint_merge"
    "gc_merge"
    "compress_algorithm=zstd:3"
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
        "i2c-dev"
        "i2c-piix4"
      ];

      luks.devices = {
        "crypt_nix" = {
          device = "/dev/disk/by-uuid/4f2a9f8e-0bab-4cfb-8315-30e800569c3b";
          allowDiscards = true;
          #reusePassphrases = true;
        };

        "crypt_persist" = {
          device = "/dev/disk/by-uuid/af2d4001-7335-480b-8881-02ccf8a6a028";
          allowDiscards = true;
          #reusePassphrases = true;
        };

        "crypt_media" = {
          device = "/dev/disk/by-uuid/443384c0-c0fd-4cba-a48b-71fc2d9b02f7";
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
      device = "/dev/disk/by-uuid/6040-663D";
      fsType = "vfat";
      options = fsOptBase ++ [ "noexec" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/fa719edf-859e-4efe-916f-e3e234f419e9";
      fsType = "f2fs";
      options = fsOptBase ++ f2fsOpt;
      neededForBoot = true;
    };

    "/persist" = {
      device = "/dev/disk/by-uuid/2ecc5c06-140b-4e03-a7b8-8a4e262d9171";
      fsType = "f2fs";
      options = fsOptBase ++ f2fsOpt;
      neededForBoot = true;
    };

    "/media" = {
      device = "/dev/disk/by-uuid/ecd043a6-4e81-4c94-b423-9280e3bb771c";
      fsType = "f2fs";
      options = fsOptBase ++ f2fsOpt ++ [ "noexec" ];
      neededForBoot = true;
    };
  };

  hardware.video.hidpi.enable = lib.mkDefault true;
}
