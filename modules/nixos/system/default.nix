{ config, options, lib, pkgs, ... }:

let
    cfg         = config.system;
    isAmdCpu    = cfg.cpu == "amd";
    isIntelCpu  = cfg.cpu == "intel";
    isAmdGpu    = cfg.gpu == "amd";
    isIntelGpu  = cfg.gpu == "intel";
    isNvidiaGpu = cfg.gpu == "nvidia";
    virtEnabled = config.virtualisation.libvirtd.enable;
    isDesktop   = cfg.kind == "desktop";
    isLaptop    = cfg.kind == "laptop";
    isServer    = cfg.kind == "server"; 
    isSoc       = cfg.kind == "soc";

/*
    interactiveKernel = pkgs.linuxPackagesFor (pkgs.linux_xanmod.override {
        argsOverride = rec {
            src = pkgs.fetchFromGitHub {
            owner = "xanmod";
            repo = "linux";
            rev = "5.14.16-xanmod1-cacule";
            sha256 =
                "ro7WnN0BPxW/8sajUyGTnvmbemKJEadSBcFmjZ+Wtrs="; # lib.fakeSha256;

            };
            version = "5.14.16";
            modDirVersion = "5.14.16-xanmod1-cacule";
        };
    });

    interactiveKernel2111 = pkgs.linuxPackagesFor (pkgs.linuxKernel.kernels.linux_xanmod.override {
        argsOverride = rec {
            src = pkgs.fetchFromGitHub {
            owner = "xanmod";
            repo = "linux";
            rev = "5.14.16-xanmod1-cacule";
            sha256 =
                "ro7WnN0BPxW/8sajUyGTnvmbemKJEadSBcFmjZ+Wtrs="; # lib.fakeSha256;

            };
            version = "5.14.16";
            modDirVersion = "5.14.16-xanmod1-cacule";
        };
    });
    */


  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

in {
    options = {
        system = {
            enable = lib.mkEnableOption "Enable some low-hanging fruit kernel hardenening.";
            kind = lib.mkOption {
                type = lib.types.enum ["desktop" "laptop" "server" "soc" false];
                default = false;
                example = "desktop";
                description = "What kind of system is this?";
            };
            cpu = lib.mkOption {
                type = lib.types.enum ["amd" "intel" false];
                default = false;
                example = "amd";
                description = "What brand is the cpu?";
            };
            gpu = lib.mkOption {
                type = lib.types.enum ["amd" "intel" "nvidia" false];
                default = false;
                example = "amd";
                description = "What brand is the gpu?";
            };
            ssdBoot = lib.mkOption {
                type = lib.types.bool;
                default = false;
                example = true;
                description = "What brand is the gpu?";
            };
        };
    };
    config = lib.mkIf (cfg.enable) {
        boot = {
            extraModulePackages = lib.mkIf (isLaptop) (with config.boot.kernelPackages; [ acpi_call ]);
            extraModprobeConfig = lib.mkIf ((isAmdCpu || isIntelCpu) && virtEnabled)  ''
                options kvm_${if isAmdCpu then "amd" else "intel"} nested=1
                options kvm_${if isAmdCpu then "amd" else "intel"} emulate_invalid_guest_state=0
                options kvm ignore_msrs=1
            '';
            kernelPackages = lib.mkIf (isDesktop || isLaptop) pkgs.linuxKernel.packages.linux_xanmod; # interactiveKernel2111;
            
            kernelModules = [
                (lib.optionalString (isAmdCpu   && virtEnabled) "kvm-amd")
                (lib.optionalString (isIntelCpu && virtEnabled) "kvm-intel" )
                (lib.optionalString (isAmdGpu) "amdgpu")
                (lib.optionalString (isDesktop || isLaptop) "i2c-dev")
                (lib.optionalString (isLaptop) "acpi_call")
            ];

            kernel.sysctl = lib.mkIf cfg.ssdBoot {
                # * Increase system responsiveness
                # The swappiness sysctl parameter represents the kernel's preference (or avoidance) of swap space. Swappiness can have a value between 0 and 100, the default value is 60.
                # A low value causes the kernel to avoid swapping, a higher value causes the kernel to try to use swap space. Using a low value on sufficient memory is known to improve responsiveness on many systems.
                "vm.swappiness" = 10;

                # The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
                # Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
                "vm.vfs_cache_pressure" = 50;

                # This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
                # Disable NMI watchdog
                #"kernel.nmi_watchdog" = 0;

                # Contains, as a percentage of total available memory that contains free pages and reclaimable
                # pages, the number of pages at which a process which is generating disk writes will itself start
                # writing out dirty data (Default is 20).
                "vm.dirty_ratio" = 5;

                # Contains, as a percentage of total available memory that contains free pages and reclaimable
                # pages, the number of pages at which the background kernel flusher threads will start writing out
                # dirty data (Default is 10).
                "vm.dirty_background_ratio" = 5;

                # This tunable is used to define when dirty data is old enough to be eligible for writeout by the
                # kernel flusher threads.  It is expressed in 100'ths of a second.  Data which has been dirty
                # in-memory for longer than this interval will be written out next time a flusher thread wakes up
                # (Default is 3000).
                #vm.dirty_expire_centisecs = 3000

                # The kernel flusher threads will periodically wake up and write old data out to disk.  This
                # tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
                "vm.dirty_writeback_centisecs" = "1500";
            };
        };
        environment = {
            systemPackages = [] ++ 
                lib.optional (isNvidiaGpu) [ nvidia-offload ] ++
                (if (isLaptop || isDesktop) then [ pkgs.ddcutil] else []);
            extraInit = lib.mkIf (isLaptop || isDesktop) "export ZDOTDIR=\"$HOME/.config/zsh\"";
        };
        hardware = {
            enableRedistributableFirmware = (isAmdCpu || isIntelCpu || isNvidiaGpu);
            cpu = {
                amd.updateMicrocode = lib.mkIf   (isAmdCpu  ) true;
                intel.updateMicrocode = lib.mkIf (isIntelCpu) true;
            };
            opengl = {
                extraPackages = 
                    if isAmdGpu then 
                        with pkgs; [ rocm-opencl-icd rocm-opencl-runtime]
                    else if (isIntelGpu) then
                        with pkgs; [ intel-compute-runtime vaapiIntel vaapiVdpau libvdpau-va-gl ]
                    else
                        [];
         
                extraPackages32 = lib.mkIf (isIntelCpu) (with pkgs.pkgsi686Linux; [ vaapiIntel ]);
                # Vulkan
                driSupport = true;
                driSupport32Bit = true;
            };
        };
        
        services = {
            timesyncd.enable = lib.mkIf isLaptop false;
            ntp.enable = lib.mkIf isLaptop false;
            chrony = lib.mkIf isLaptop {
                enable = true;
                servers = [
                    "0.uk.pool.ntp.org"
                    "1.uk.pool.ntp.org"
                    "2.uk.pool.ntp.org"
                    "3.uk.pool.ntp.org"
                    "0.nixos.pool.ntp.org"
                    "1.nixos.pool.ntp.org"
                    "2.nixos.pool.ntp.org"
                    "3.nixos.pool.ntp.org"
                ];
                serverOption = "offline";
                extraConfig = ''
                    # In first three updates step the system clock instead of slew
                    # if the adjustment is larger than 1 second.
                    makestep 1.0 3
                    pool time.nist.gov iburst
                    server time.cloudflare.com nts iburst
                    pool nixos.pool.ntp.org iburst
                    pool pool.ntp.org iburst
                    pool amazon.pool.ntp.org iburst
                    initstepslew ${toString config.services.chrony.initstepslew.threshold} ${lib.concatStringsSep " " config.networking.timeServers}
                    # Enable kernel synchronization of the real-time clock (RTC).
                    rtcsync
                    ntsdumpdir /var/lib/chrony/nts
                '';
            };
            tlp = lib.mkIf isLaptop {
                enable = true;
                settings = {
                    "SOUND_POWER_SAVE_ON_AC" = 0;
                    "SOUND_POWER_SAVE_ON_BAT" = 1;
                    "SOUND_POWER_SAVE_CONTROLLER" = "Y";
                    "BAY_POWEROFF_ON_AC" = 0;
                    "BAY_POWEROFF_ON_BAT" = 1;
                    "DISK_APM_LEVEL_ON_AC" = "254 254";
                    "DISK_APM_LEVEL_ON_BAT" = "128 128";
                    "DISK_IOSCHED" = "none none";
                    "SATA_LINKPWR_ON_AC" = "med_power_with_dipm max_performance";
                    "SATA_LINKPWR_ON_BAT" = "min_power";
                    "MAX_LOST_WORK_SECS_ON_AC" = 15;
                    "MAX_LOST_WORK_SECS_ON_BAT" = 60;
                    "NMI_WATCHDOG" = 0;
                    "WIFI_PWR_ON_AC" = "off";
                    "WIFI_PWR_ON_BAT" = "on";
                    "WOL_DISABLE" = "Y";
                    "CPU_SCALING_GOVERNOR_ON_AC" = "powersave";
                    "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
                    "CPU_MIN_PERF_ON_AC" = 0;
                    "CPU_MAX_PERF_ON_AC" = 100;
                    "CPU_MIN_PERF_ON_BAT" = 0;
                    "CPU_MAX_PERF_ON_BAT" = 50;
                    "CPU_BOOST_ON_AC" = 1;
                    "CPU_BOOST_ON_BAT" = 1;
                    "SCHED_POWERSAVE_ON_AC" = 0;
                    "SCHED_POWERSAVE_ON_BAT" = 1;
                    "ENERGY_PERF_POLICY_ON_AC" = "performance";
                    "ENERGY_PERF_POLICY_ON_BAT" = "power";
                    "RESTORE_DEVICE_STATE_ON_STARTUP" = 0;
                    "RUNTIME_PM_ON_AC" = "on";
                    "RUNTIME_PM_ON_BAT" = "auto";
                    "PCIE_ASPM_ON_AC" = "default";
                    "PCIE_ASPM_ON_BAT" = "powersupersave";
                    "USB_AUTOSUSPEND" = 1;
                };
            };
            xserver =  lib.mkIf config.services.xserver.enable {
                videoDrivers = lib.mkIf (isAmdGpu || isNvidiaGpu || isIntelGpu) [
                    (lib.optionalString (isAmdGpu) "amdgpu")
                    (lib.optionalString (isNvidiaGpu) "nvidia")
                    (lib.optionalString (isIntelGpu) "modesetting")
                ];
                useGlamor = lib.mkIf isIntelGpu true;
                libinput.enable = lib.mkIf isLaptop true;
            };
            udev = {
                extraRules =''
                    ${lib.optionalString (isLaptop) ''
                    # Save Power
                    ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"

                    # Allow members of video to change laptop monitor  brightness
                    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
                    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
                    ''}
                    ${lib.optionalString (isLaptop || isDesktop) ''
                    # Allow members of input change keyboar brightness
                    ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chgrp input /sys/class/leds/%k/brightness"
                    ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"

                    # Allow members of i2c to change external monitor  brightness
                    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
                    ''}
                '';
            };
        };
        zramSwap = lib.mkIf (isDesktop || isLaptop) {
            enable = true;
            algorithm = "zstd";
        };
    };
}

