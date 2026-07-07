{ config, pkgs, lib, user, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.05";
  programs = {
    home-manager.enable = true;
  } // import ../shared/home.nix { inherit config pkgs lib; };
  home.packages = with pkgs;
    let
      shared-packages = import ../shared/packages.nix { inherit pkgs; };
    in
    shared-packages
    ++ [
      chromium
      nerd-fonts.jetbrains-mono
      socat
    ];
  fonts.fontconfig.enable = true;
}
