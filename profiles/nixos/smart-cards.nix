{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      opensc
    ];
  };
  services = {
    pcscd = {
      enable = true;
      plugins = with pkgs; [
        pcsclite
        opensc # Encryption
        openssl
        pcsctools
        libusb
        libusb1
        ccid
        pcsc-cyberjack
        encfs
        cryptsetup # Encrypted USB sticks etc
        pinentry # GPG password entry from the terminal
        gnupg # Encryption key management
        gnupg1orig
        pcmciaUtils # PCMCIA Tools
        acsccid # SmartCard Apps
        glibc # Para o WebSigner Certsign
        chrome-token-signing # Chrome and Firefox extension for signing with your eID on the web
      ];
    };
  };
}
