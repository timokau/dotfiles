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

    xsession.enable = true;
    xsession.windowManager.command = ''
      PATH="${pkgs.herbstluftwm}/bin:$PATH" herbstluftwm
    '';

    # Work around for https://github.com/dunst-project/dunst/discussions/1254
    systemd.user.services.dunst_fullscreen = {
      Unit = {
        Description = "Redraw dunst when a fullscreen window is active.";
        After = [ "graphical-session-pre.target" ];
      };

      Service = {
        ExecStart = ''
          $HOME/bin/fullscreen_focused_hook
        '';
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
