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
    emacspkg = pkgs.symlinkJoin {
      name = "emacs-with-env";
      paths = [ pkgs.emacs ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for binary in "$out/bin/"*; do
          # Set DOOMLOCALDIR to a writable location outside of the emacs
          # configuration directory (which is occupied by a read-only copy of
          # doom-emacs).
          # Ensure `ripgrep` is in the PATH, since it is used by doom-emacs.
          # Ensure `sqlite` is in the PATH, since it is used by org-roam-v1.
          wrapProgram "$binary" \
            --set-default "DOOMLOCALDIR" "~/.local/share/doom" \
            --prefix PATH : "${pkgs.sqlite}/bin:${pkgs.ripgrep}/bin"
        done
      '';
    };
    doom-emacs = pkgs.stdenv.mkDerivation rec {
      pname = "doom-emacs";
      version = "bea3cc161c0a803dcf574f32ee555dccf565a5ce";

      src = pkgs.fetchFromGitHub {
        owner = "hlissner";
        repo = "doom-emacs";
        rev = version;
        hash = "sha256-B4N+UQ0SvnCH0Hqc62Wl1KS6WcTBGLag0BoH3UZGbgo=";
      };

      nativeBuildInputs = [
        pkgs.makeWrapper
      ];

      installPhase = ''
        runHook preInstall
        cp -r . "$out";
        runHook postInstall
      '';

      # Make sure the scripts use our emacs package
      preFixup = ''
        for binary in "$out/bin/"*; do
          if [[ -x "$binary" ]]; then
            wrapProgram "$binary" \
              --prefix PATH : "${emacspkg}/bin"
          fi
        done
      '';
    };
    doomSync = ''
      # Pass "-u" to "upgrade" packages. Since packages are pinned, this only
      # updates packages when the pins are updated.
      ${doom-emacs}/bin/doom --yes sync -u
      echo "Remember to restart the emacs daemon: systemctl --user restart emacs.service"
    '';
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
    home = {
      packages = with pkgs; [
        emacspkg # The emacs package, configured to use doom-emacs.
        doom-emacs # Include the doom-emacs executables in the PATH
        # A desktop file to register emacsclient as a handler for org-protocol
        org-protocol-handler-registration
      ];
      file.".doom.d/config.org" = {
       source = ../doom-emacs/config.org;
       onChange = doomSync;
      };
      file.".doom.d/init.el" = {
       source = ../doom-emacs/init.el;
       onChange = doomSync;
      };
      file.".doom.d/packages.el" = {
       source = ../doom-emacs/packages.el;
       onChange = doomSync;
      };
    };
    xdg = {
      enable = true;
      # Write / symlink a copy of the doom-emacs distribution to the emacs
      # configuration directory. The "real" user config is in DOOMDIR
      # (~/.doom.d).
      configFile."emacs" = {
        source = doom-emacs;
        onChange = doomSync;
      };
    };
    services.emacs = {
      enable = true;
      package = emacspkg;
      client.enable = true;
    };
  };
}
