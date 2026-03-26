{ config, pkgs, user, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs;
    let
      shared-packages = import ../shared/packages.nix { inherit pkgs; };
    in
    shared-packages
    ++ [
      ghostty
      socat
    ];
}
