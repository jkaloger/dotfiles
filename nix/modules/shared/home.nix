{
  config,
  pkgs,
  lib,
  ...
}:

{
  direnv = {
    enableZshIntegration = true;
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
        log_format = "[36m▪[0m [2m%s[0m";
      };
    };
  };
}
