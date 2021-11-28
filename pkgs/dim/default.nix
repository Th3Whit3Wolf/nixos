{ lib, stdenv, pkgs, fetchFromGitHub, rustPlatform, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "dim";
  version = "v0.3.0-rc6";

  src = fetchFromGitHub {
    owner = "Dusk-Labs";
    repo = pname;
    rev = version;
    sha256 = "FgxX7pOb0dvWZK9fA8e/Jif0AE7TCKew6GTIBSribjE=";
  };

  cargoPatches = [
    # a patch file to add/update Cargo.lock in the source code
    ./Add-Cargo.lock.patch
  ];

  cargoSha256 = "sha256-q0OvPp8C+9mqOyZ3O/9zrPnlFW699B7JxoY6UQ9AZIY=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = with pkgs; [
    libdrm
    libdrm.dev
    libva
    libva.dev
    fribidi
    libtheora
    libvorbis
    ffmpeg-full
    openssl
    openssl.dev
    harfbuzz
    sqlite
    gcc
    fontconfig
  ];

  preBuildPhase = ''
    yarn --cwd $PWD/ui/ && yarn --cwd $PWD/ui/ build
  '';

  meta = with lib; {
    description = "Dim, a media manager fueled by dark forces.";
    homepage = "https://github.com/Dusk-Labs/dim";
    license = with licenses; [ gpl2 ];
    maintainers = with maintainers; [ th3whit3wolf ];
  };
}
