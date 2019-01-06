{ config, pkgs, lib, ... }:
{
  imports = [
    ./home/configuration.nix
  ];

  home = {
    graphical = true;
  };
}
