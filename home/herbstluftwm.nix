{ config, pkgs, lib, ... }:
let
  cfg = config.herbstluftwm;
in
with lib;
{
  options.herbstluftwm = {
    enable = mkEnableOption "Herbstluftwm window manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sxhkd # I'm using a separate sxhkd configuration just for controlling the window manager
      i3lock # lock screen
      xtitle # TODO necessary?
      xautolock # lock when idle
      dzen2 # for the bar
    ];

    xdg.configFile."herbstluftwm" = {
      source = ../herbstluftwm/.config/herbstluftwm;
      recursive = true;
    };

    programs.autorandr.hooks.postswitch.hc-reload = "${pkgs.herbstluftwm}/bin/herbstclient reload";

    xsession.enable = true;
    xsession.windowManager.command = ''
      PATH="${pkgs.herbstluftwm}/bin:$PATH" herbstluftwm
    '';
  };
}
