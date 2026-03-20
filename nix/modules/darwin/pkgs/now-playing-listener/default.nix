{ stdenv, swift, lib }:

stdenv.mkDerivation {
  pname = "now-playing-listener";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ swift ];

  buildPhase = ''
    swiftc -O -o now-playing-listener main.swift
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp now-playing-listener $out/bin/
  '';

  meta = {
    description = "Listens for Spotify/Music playback changes and triggers sketchybar events";
    platforms = lib.platforms.darwin;
  };
}
