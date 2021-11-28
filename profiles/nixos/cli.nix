{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      binutils
      cached-nix-shell
      compsize
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      gnumake
      iputils
      jq
      manix
      moreutils
      nix-index
      nmap
      openssl
      usbutils
      utillinux
      wget
      whois

      # Rust Tools
      bat
      bat-extras.prettybat
      bat-extras.batman
      bat-extras.batgrep
      bat-extras.batdiff
      bat-extras.batwatch
      bingrep
      bottom
      diskonaut
      du-dust
      exa
      fd
      hexyl
      hyperfine
      just
      nushell
      procs
      ripgrep
      skim
      tealdeer
      tokei
      xsv
      xxv
      zoxide
    ];
  };
}
