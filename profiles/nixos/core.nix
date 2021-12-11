{ config, pkgs, lib, ... }:
let
  normalUser = builtins.attrNames (lib.filterAttrs (n: v: v.isNormalUser) config.users.users);
  experimental-features = [ "flakes" "nix-command"  "recursive-nix" ];
in {
  environment = {
    etc = {
      # Automatic log out from virtual consoles
      "profile.d/shell-timeout.sh".text = ''
        # Log user out in 30 minutes
        "TMOUT="\$(( 60*30 ))";
        [ -z "\$DISPLAY" ] && export TMOUT;
        case \$( /usr/bin/tty ) in /dev/tty[0-9]*)
            export TMOUT;;
        esac
      '';
    };
    pathsToLink = [
      "/share/nix-direnv"
      (lib.optionalString (lib.any (u: (lib.attrByPath ["shell"] false u) == pkgs.zsh ) normalUser) "/share/zsh")
    ];
    systemPackages = with pkgs; [ direnv nix-direnv ];
  };
  
  nix = {
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "recursive-nix" "kvm" ];
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 40d";
      dates = "weekly";
    };
    optimise.automatic = true;
    package = pkgs.nixUnstable;
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
      extra-experimental-features = ${
        lib.concatStringsSep " " experimental-features
      }
      warn-dirty = false
      http2 = true
    '';
  };

  services.udev.extraRules = ''
    # set scheduler for NVMe
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # set scheduler for SSD and eMMC
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # set scheduler for rotating disks
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq" 
        '';
}

