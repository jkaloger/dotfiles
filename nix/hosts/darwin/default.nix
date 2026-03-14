{ config, pkgs, user, ... }:

{
  imports = [
    ../../modules/darwin
  ];

  environment.systemPackages = [
    pkgs.vim
  ];

  system = {
    stateVersion = 6;

    primaryUser = user;

    defaults = {
      dock = {
        autohide = true;
        orientation = "right";
      };
    };
  };
}
