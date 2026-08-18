# Instalcja Millenium-Steam bez udziału Flake. Nowa wersja = podmiana rev i sha
{ config, lib, pkgs, ... }:
let
  millenniumSrc = pkgs.fetchFromGitHub {
    owner = "SteamClientHomebrew";
    repo = "Millennium";
    rev = "v3.4.1";
    sha256 = "zgr4cdJfye4qunpD3ClNnZ9D1WPGQAXV0CnYwEbB52s=";
  };

  millennium = pkgs.callPackage
    "${millenniumSrc}/packages/nix/millennium.nix"
    { millennium-src = millenniumSrc; };

  millennium-steam = pkgs.callPackage
    "${millenniumSrc}/packages/nix/steam.nix"
    { inherit millennium; };
in
{
  programs.steam.package = millennium-steam;
}
