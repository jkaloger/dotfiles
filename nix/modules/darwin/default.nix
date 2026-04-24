{
  config,
  pkgs,
  lib,
  home-manager,
  user,
  ...
}:

let
  now-playing-listener = pkgs.callPackage ./pkgs/now-playing-listener { };
in
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

  launchd.user.agents.now-playing-listener = {
    serviceConfig = {
      ProgramArguments = [ "${now-playing-listener}/bin/now-playing-listener" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/now-playing-listener.log";
      StandardErrorPath = "/tmp/now-playing-listener.log";
    };
  };

  launchd.user.agents.ollama = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/ollama.log";
      StandardErrorPath = "/tmp/ollama.log";
    };
  };
}
