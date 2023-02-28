{ config, pkgs, lib, ... }:
let
  cfg = config.emacs;
in
{
  options.emacs = {
    enable = lib.mkEnableOption "Emacs";
  };

  # Emacs and its plugins is configured with doom-emacs. That is not quite as
  # nice as using nix directly, but its relatively close since doom-emacs pins
  # all its packages. Doom saves us a lot of effort, so this is a compromise
  # for practicality's sake.
  config = let
    emacspkg = pkgs.callPackage (
      # To use the latest version (impure)
      # builtins.fetchTarball {url = "https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz"; }
      pkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "nix-doom-emacs";
        rev = "e92e5b6021b1ad4290e051111010ba51921507cd";
        hash = "sha256-mf+RaqdCqqLraVVOQ5c8LRj+9ChnVzsUNlOjJSPdBbc=";
      }
    ) {
      doomPrivateDir = pkgs.callPackage ../doom-emacs {};
    };
    org-protocol-handler-script = pkgs.writeScript "handlerScript.sh" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.libnotify}/bin/notify-send --expire-time=1000 --urgency=low "Captured"
      exec ${emacspkg}/bin/emacsclient -- "$@"
    '';
    org-protocol-handler-registration = pkgs.makeDesktopItem {
      name = "org-protocol";
      exec = "${org-protocol-handler-script} %u";
      desktopName = "org-protocol";
      mimeTypes = ["x-scheme-handler/org-protocol"];
    };
  in lib.mkIf cfg.enable {
    programs.fish = {
      shellAliases = {
        # Emacs TUI
        em = "${emacspkg}/bin/emacsclient --tty";
        emg = "${emacspkg}/bin/emacsclient --create-frame --no-wait";
      };
    };
    home = {
      packages = with pkgs; [
        emacspkg # The emacs package, configured to use doom-emacs.
        # A desktop file to register emacsclient as a handler for org-protocol
        org-protocol-handler-registration
      ];
    };
    services.emacs = {
      enable = true;
      package = emacspkg;
      client.enable = true;
    };
  };
}
