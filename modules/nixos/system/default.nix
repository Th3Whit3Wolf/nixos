{ config, options, lib, pkgs, ... }:
with lib;
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
    hasUSBMon   = cfg.usbMonitor;

    sysKindEnum            = types.enum [
            "desktop"
            "laptop"
            "server"
            "soc"
        ];
    cpuEnum                = types.enum  [
            "amd" 
            "intel"
        ];
    gpuEnum                = types.enum  [
            "amd"
            "intel"
            "nvidia"
        ];
    laptopManufacturerEnum = types.enum [
            "asus"
        ];
    laptopModelEnum        = types.enum [
            "ZenBook_UM425IA" 
            "ZenBook_UX425IA"
        ];

    isLTModel = models: if cfg.laptopModel != null then any (model: cfg.laptopModel == model) models else false;

    mkeUdevRule = listOfLists:
    let 
        fromListToString = ls:
            let
                KEY' = builtins.elemAt ls 0;
                OP' = builtins.elemAt ls 1;
                VAL = builtins.elemAt ls 2;

                KEY =  if hasInfix "{" KEY' then 
                    let 
                        splitKEY = splitString "{" KEY'; 
                        kAttrK = toUpper (builtins.elemAt splitKEY 0);
                        kAttrV = removeSuffix "}" (builtins.elemAt splitKEY 1);
                    in
                        "${kAttrK}{${kAttrV}}"
                    else toUpper KEY';

                OP = if OP' == "eq" then
                        "==" 
                    else if OP' == "neq" then
                        "!="
                    else if OP' == "is" then
                        "="
                    else if OP' == "inc" then
                        "+="
                    else if OP' == "const" then
                        ":="
                    else
                        traceVal OP';
            in
                ''${KEY}${OP}"${VAL}"'';
        assingments = forEach listOfLists (list: fromListToString list);
    in
    concatStringsSep ", " assingments;

    genAction    = act:    ["action"    "eq"  "${if isString act then act else concatStringsSep "|" act }"];    
    genGroup     = grp:    ["group" "is" grp];
    genKernel    = krnl:   ["kernel"    "eq"  krnl];
    genMode      = md:     ["mode"      "is"  "${if isString md then md else builtins.toString md}"];
    genRun       = run:    ["run"       "inc" run];
    genSubSystem = subsys: ["subsystem" "eq"  subsys];

    genAttrIS = key: val: ["attr{${key}}" "is" val];
    genAttrEQ = key: val: ["attr{${key}}" "eq" val];
    genEnvIS  = key: val: ["env{${key}}"  "is" val];
    genEnvEQ  = key: val: ["env{${key}}"  "eq" val];

    actionAdd    = genAction "add";
    actionChange = genAction "change";
    actionAddOrChange = genAction ["add" "change"];

    groupVideo = genGroup "video";

    mode0664 = genMode "0664";
    
    subsystemBacklight = genSubSystem "backlight";
    subsystemLED       = genSubSystem "led";
    subsystemI2C       = genSubSystem "i2c-dev";
    subsystemScsiHost  = genSubSystem "scsi_host";

    genChangeGroup   = grp: grpPath:  genRun "${pkgs.coreutils}/bin/chgrp ${grp} ${grpPath}";
    genGroupWriteMod = path:          genRun "${pkgs.coreutils}/bin/chmod g+w ${path}";
    runSh            = cmd:           genRun "${pkgs.bash}/bin/bash -c '${cmd}'";

    genGroupPriv  = subsystem: group: privPath:
        let
            SUBSYSTEM = if isString subsystem then genSubSystem subsystem else subsystem;
            chgrp = mkeUdevRule [ actionAdd SUBSYSTEM (genChangeGroup   group privPath) ];
            chmod = mkeUdevRule [ actionAdd SUBSYSTEM (genGroupWriteMod       privPath) ];
        in
        "${chgrp}\n${chmod}";

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
            enable = mkEnableOption "Enable some low-hanging fruit kernel hardenening.";
            kind = mkOption {
                type = types.nullOr sysKindEnum;
                default = null;
                example = "desktop";
                description = "What kind of system is this?";
            };
            laptopManufacturer = mkOption {
                type = types.nullOr laptopManufacturerEnum;
                default = null;
                example = "asus";
                description = ''
                    Who manufactured your laptop?

                    If unsure run `nix-shell -p dmidecode --run 'sudo dmidecode | grep Manufacturer | head -n1'`
                '';
            };
            laptopModel = mkOption {
                type = types.nullOr laptopModelEnum;
                default = null;
                example = "ZenBook_UM425IA";
                description = ''
                    What model is your laptop?

                    If unsure run `nix-shell -p dmidecode --run 'sudo dmidecode | grep "Product Name:"'`
                '';
            };
            cpu = mkOption {
                type = types.nullOr cpuEnum;
                default = null;
                example = "amd";
                description = "What brand is the cpu?";
            };
            gpu = mkOption {
                type = types.nullOr gpuEnum;
                default = null;
                example = "amd";
                description = "What brand is the gpu?";
            };
            ssdBoot = mkOption {
                type = types.bool;
                default = false;
                example = true;
                description = "What brand is the gpu?";
            };
            usbMonitor = mkOption {
                type = types.bool;
                default = false;
                example = true;
                description = "Does this device use a USB-C monitor?";
            };
            backlightName = mkOption {
                type = types.nullOr types.string;
                default = null;
                example = "amdgpu_bl0";
                description = "Name of backlight to give video group access to";
            };
            keyboardName = mkOption {
                type = types.nullOr types.string;
                #type = types.nullOr (types.either (types.listOf types.string) types.string);
                default = null;
                example = "asus::kbd_backlight";
                description = "Name of led to give video group access to";
            };
            externMonitorName = mkOption {
                type = types.nullOr types.string;
                #type = types.nullOr (types.either (types.listOf types.string) types.string);
                default = null;
                example = "i2c12";
                description = "Name of i2c device to give video group access to";
            };
        };
    };

    config = mkIf (cfg.enable) {
        boot = {
            extraModulePackages = mkIf (isLaptop) (with config.boot.kernelPackages; [ acpi_call ]);
            extraModprobeConfig = mkIf ((isAmdCpu || isIntelCpu) && virtEnabled)  ''
                options kvm_${if isAmdCpu then "amd" else "intel"} nested=1
                options kvm_${if isAmdCpu then "amd" else "intel"} emulate_invalid_guest_state=0
                options kvm ignore_msrs=1
            '';
            kernelPackages = mkIf (isDesktop || isLaptop) pkgs.linuxKernel.packages.linux_xanmod; 
            
            kernelModules = [
                (optionalString (isAmdCpu   && virtEnabled) "kvm-amd")
                (optionalString (isIntelCpu && virtEnabled) "kvm-intel" )
                (optionalString (isAmdGpu) "amdgpu")
                (optionalString (isDesktop || isLaptop) "i2c-dev")
                (optionalString (isLaptop) "acpi_call")
            ];

            kernel.sysctl = mkIf cfg.ssdBoot {
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
                optional (isNvidiaGpu) [ nvidia-offload ] ++
                (if (isLaptop || isDesktop) then [ pkgs.ddcutil] else []) ++
                (if (isAmdGpu) then [ pkgs.mesa] else []);
            extraInit = mkIf (isLaptop || isDesktop) "export ZDOTDIR=\"$HOME/.config/zsh\"";
        };
        hardware = {
            enableRedistributableFirmware = (isAmdCpu || isIntelCpu || isNvidiaGpu);
            cpu = {
                amd.updateMicrocode = mkIf   (isAmdCpu  ) true;
                intel.updateMicrocode = mkIf (isIntelCpu) true;
            };
            opengl = {
                extraPackages = 
                    if isAmdGpu then 
                        with pkgs; [ rocm-opencl-icd rocm-opencl-runtime]
                    else if (isIntelGpu) then
                        with pkgs; [ intel-compute-runtime vaapiIntel vaapiVdpau libvdpau-va-gl ]
                    else
                        [];

                extraPackages32 = mkIf (isIntelCpu) (with pkgs.pkgsi686Linux; [ vaapiIntel ]);
                # Vulkan
                driSupport = true;
                driSupport32Bit = true;
            };
            i2c = mkIf (isLTModel ["ZenBook_UM425IA" "ZenBook_UX425IA"]) {
                enable = true;
            };
        };
        
        services = {
            timesyncd.enable = mkIf isLaptop false;
            ntp.enable = mkIf isLaptop false;
            chrony = mkIf isLaptop {
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
                    initstepslew ${toString config.services.chrony.initstepslew.threshold} ${concatStringsSep " " config.networking.timeServers}
                    # Enable kernel synchronization of the real-time clock (RTC).
                    rtcsync
                    ntsdumpdir /var/lib/chrony/nts
                '';
            };
            power-profiles-daemon = mkIf isLaptop {
                enable = false;
            };
            tlp = mkIf isLaptop {
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
            xserver =  mkIf config.services.xserver.enable {
                videoDrivers = mkIf (isAmdGpu || isNvidiaGpu || isIntelGpu || hasUSBMon) [
                    (optionalString (isAmdGpu) "amdgpu")
                    (optionalString (isNvidiaGpu) "nvidia")
                    (optionalString (isIntelGpu) "modesetting")
                    (optionalString (hasUSBMon) "displaylink")
                ];
                useGlamor = mkIf isIntelGpu true;
                libinput.enable = mkIf isLaptop true;
            };
            udev = {
                extraRules =''
                    # Set Scheduler for NVMe
                    ${mkeUdevRule [ actionAddOrChange (genKernel "nvme[0-9]n[0-9]") (genAttrIS "queue/scheduler" "none")]}
                    # Set Scheduler for SSD and eMMC
                    ${mkeUdevRule [ actionAddOrChange (genKernel "sd[a-z]|mmcblk[0-9]*") (genAttrEQ "queue/rotational" "0") (genAttrIS "queue/scheduler" "mq-deadline")]}
                    # Set Scheduler for rotating disks
                    ${mkeUdevRule [ actionAddOrChange (genKernel "sd[a-z]") (genAttrEQ "queue/rotational" "1") (genAttrIS "queue/scheduler" "bfq")]}
                    
                    ${optionalString (isLaptop) ''
                    # Save Power
                    ${mkeUdevRule [ actionAdd subsystemScsiHost (genKernel "hosts*") (genAttrIS "link_power_management_policy" "med_power_with_dipm")]}
                    ''}
                    ${optionalString (cfg.backlightName != null) ''
                    # Allow members of video to change laptop monitor brightness
                    ${genGroupPriv subsystemBacklight "video" "/sys/class/backlight/${cfg.backlightName}/brightness" }

                    # This used to work but no longer does, not sure when and why this happened
                    # ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="${cfg.backlightName}", GROUP="video", MODE="0664"

                    # UNSAFE allow ALL members of video group full access to ALL backlight devices
                    # ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
                    # ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
                    ''}
                    ${optionalString (cfg.keyboardName != null) ''
                    # Allow members of video to change led (keyboard) brightness
                    ${genGroupPriv subsystemLED "video" "/sys/class/leds/${cfg.keyboardName}/brightness" }

                    # This used to work but no longer does, not sure when and why this happened
                    # ACTION=="add", SUBSYSTEM=="leds", KERNEL=="${cfg.keyboardName}", GROUP="video", MODE="0664"

                    # UNSAFE allow ALL members of video group full access to ALL led devices
                    # ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
                    # ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
                    ''}
                    ${optionalString (cfg.externMonitorName != null) ''
                    # Allow members of video to change i2c device (external monitor) brightness
                    ${mkeUdevRule [ (genKernel cfg.externMonitorName) subsystemI2C groupVideo mode0664]}

                    # UNSAFE allow ALL members of i2c group full access to ALL i2c devices
                    # KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
                    ''}

                    ${optionalString (isLTModel ["ZenBook_UM425IA" "ZenBook_UX425IA"]) ''
                    # Should stop charging after 60% battery
                    ${mkeUdevRule [ actionAdd (genKernel "asus-nb-wmi") (runSh "echo 60 > /sys/class/power_supply/BAT?/charge_control_end_threshold")]}
                    ''}

                '';
            };
        };

        systemd.services = {

            asus-touchpad-numpad = mkIf (isLTModel ["ZenBook_UM425IA" "ZenBook_UX425IA"]) {
                description = "Asus Touchpad to Numpad Handler";
                documentation = ["https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver"];
                path = [ pkgs.i2c-tools ];
                script = ''
                    cd ${pkgs.fetchFromGitHub {
                    owner = "mohamed-badaoui";
                    repo = "asus-touchpad-numpad-driver";
                    # These needs to be updated from time to time
                    rev = "d80980af6ef776ee6acf42c193689f207caa7968";
                    sha256 = "sha256-JM2wrHqJTqCIOhD/yvfbjLZEqdPRRbENv+N9uQHiipc=";
                    }}
                    # In the last argument here you choose your layout.
                    ${pkgs.python3.withPackages(ps: [ ps.libevdev ])}/bin/python asus_touchpad.py ux433fa
                '';
                # Probably needed because it fails on boot seemingly because the driver
                # is not ready yet. Alternatively, you can use `sleep 3` or similar in the
                # `script`.
                serviceConfig = {
                    StandardInput = "tty-force";
                    StandardOutput = "/var/log/asus_touchpad_numpad-driver/error.log";
                    StandardError = "/var/log/asus_touchpad_numpad-driver/error.log";
                    TimeoutSec = 5;
                    RestartSec = "2s";
                    Restart = "on-failure";
                };
                wantedBy = [ "multi-userdefault.target" ];
            };
        };

        zramSwap = mkIf (isDesktop || isLaptop) {
            enable = true;
            algorithm = "zstd";
        };
    };
}

