{
  config,
  pkgs,
  lib,
  home-manager,
  user,
  ...
}:

{
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          stateVersion = "25.05";
          packages = pkgs.callPackage ./packages.nix { };
          file = { };
        };
        programs = {
        } // import ../shared/home.nix { inherit config pkgs lib; };
      };
  };

  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  services = {
    sketchybar = {
      enable = true;
    };
  };
}
