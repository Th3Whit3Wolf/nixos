{ lib, pkgs, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "anime4kcpp";
  version = "2.5.0";
  src = builtins.fetchGit {
    url = "https://github.com/TianZerL/Anime4KCPP.git";
    #ref = "v${version}";
    rev = "63ed9313a18c038ae70f95896c94e67baa806074";
    #sha256 = "16fcb7ssj6kj687a042afaa2gq48rc8abihpm14k684ncihb2k4w";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    rocm-cmake
    libsForQt514.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    nixpkgs-fmt
    pkg-config
    opencv
    rocm-opencl-icd
    rocm-opencl-runtime
    rocm-runtime
    rocm-device-libs
    mesa
    boost
    tbb
    libsForQt514.full
    libsForQt514.qt5.qttools
    qtcreator
    ffmpeg-full
    curlFull
    curlpp
    rocclr
    gcc
  ];

  configurePhase = ''
    mkdir build && cd build
    cmake .. -DBuild_GUI=ON -DRyzen_Optimization=ON
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    cp -r bin $out/
  '';
}
