{ config, pkgs, lib, ... }:
let
  cfg = config.emacs;
in
{
  options.emacs = {
    enable = lib.mkEnableOption "Emacs";
  };

  config = let
    emacspkg = pkgs.emacs;
  in lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        emacspkg
      ];
    };
    services.emacs = {
      enable = true;
      package = emacspkg;
      client.enable = true;
    };
  };
}
