{ config, pkgs, lib, ... }:
{
  imports = [
    ./home/configuration.nix
  ];

  home = {
    graphical = !(builtins.pathExists ./home-configuration/headless);
  };
}
