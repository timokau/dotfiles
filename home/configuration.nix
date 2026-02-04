{ config
, pkgs # nixpkgs is pinned through nixPath in the system config
, lib
, ...
}:
let
  cfg = config.home;
  chromium-widevine = (pkgs.chromium.override { enableWideVine = true; });
  # Wrap a web app to make it seem similar to a native application with a desktop file
  makeChromiumDesktopApp = name: url: extraArgs: (lib.optionalString cfg.graphical ''
    [Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Type=Application
    Terminal=false
    Exec=${chromium-widevine}/bin/chromium --class '${name}' --app=${url} ${extraArgs}
    Name=${name}
  '');
in
  # TODO cleanup services
  # fd --no-ignore --changed-before 7d . ~/.cache --exec rm -f {}
  # fd --no-ignore --changed-before 1d --type f --type e . ~/.config --exec trash-put {}
  # TODO something similar .local?
with pkgs.lib; {
  imports = [
    ./neovim.nix # editor
    ./emacs.nix # editor and more
    ./taskwarrior.nix # todo list and task management
    ./newsboat.nix # rss reader
    ./git.nix
    ./ranger.nix # file manager
    ./mutt.nix # mail
    ./scripts.nix
    ./herbstluftwm.nix # window manager
    ./kitty.nix # terminal emulator
    ./redshift.nix # shift screen light to red (away from blue) in the evening to tell the brain its night time
  ];

  options.home = {
    graphical = mkOption {
      type = types.bool;
      default = true;
      description = "Weather to install a graphical environment or not";
    };
    full = mkOption {
      type = types.bool;
      default = true;
      description = "Weather to install all packages, regardless of space";
    };
  };

  config = {
    herbstluftwm.enable = cfg.graphical;
    kitty.enable = cfg.graphical;
    redshift.enable = cfg.graphical;
    emacs.enable = true;

    home.stateVersion = "18.09";

    # only tools I use directly
    # tools used in scripts should be listed somewhere else
    home.packages = let
      nix-bisect = pkgs.python3.pkgs.buildPythonPackage rec {
        pname = "nix-bisect";
        version = "3b18985913cf32e62f3a5d3f9ccafb507fed9080";
        pyproject = true;
        # src = lib.cleanSource /home/timo/repos/nix-bisect;
        src = pkgs.fetchFromGitHub {
          owner = "timokau";
          repo = "nix-bisect";
          rev = version;
          hash = "sha256-wvB8Km+DY0DJNaTAemUPZOfTCmCg6ZDnOSgGP4NEO68=";
        };
        propagatedBuildInputs = with pkgs.python3.pkgs; [
          appdirs
          pexpect
          numpy
        ];
        build-system = with pkgs.python3.pkgs; [setuptools];
      };

      # https://nixos.wiki/wiki/Flakes#Using_flakes_with_stable_Nix
      # The packaged tools are generally more up to date than the nixpkgs version
      nix-ai-tools-pkgs = (import (
        fetchTarball {
          url = "https://github.com/edolstra/flake-compat/archive/ff81ac966bb2cae68946d5ed5fc4994f96d0ffec.tar.gz";
          sha256 = "19d2z6xsvpxm184m41qrpi1bplilwipgnzv9jy17fgw421785q1m";
      }) {
        src = pkgs.fetchFromGitHub {
          owner = "numtide";
          repo = "nix-ai-tools";
          rev = "a23961fc90c59a0cd7f4886c0bcc0efd796a8287";
          hash = "sha256-2re/gbzb2fZHpQp6u7mM5rBVhf55McYdwOeGdYgJNKo=";
        };
      }).defaultNix.outputs.packages.${pkgs.stdenv.hostPlatform.system};
    in with pkgs; [
      nix-ai-tools-pkgs.claude-code
      ripgrep-all # search through various files (mainly pdfs)
      zip # creating archives
      poppler-utils # work with pdfs
      watson # time tracking
      umlet # quick diagram sketching
      rmapi # interface with remarkable tablet
      zotero # reference management
      libreoffice # office suite
      pdfpc # latex beamer presentations
      entr # run command on file changes (nicer interface than inotify)
      skim # fzf clone in rust
      moreutils # usefull stuff like `vidir` bulk renaming
      ltrace # trace library calls
      gdb
      # superTuxKart # disabled since its broken on master (2020-10-20)
      teeworlds
      brightnessctl # controlling brightness on my laptop
      tmux
      htop # system monitoring
      pdfgrep # search through pdfs
      imagemagick # cli image editing
      dot2tex # graphviz <-> latex
      gnuplot # plot generation in latex
      # for quick python experiments
      (python3.withPackages (pkgs: with pkgs; [
        nix-bisect # bisect nix packages
        # rl algorithms
        black # python formatting
        notmuch # notmuch python api to sort mails
        ipython # better interactive python
        numpy # number squashing
        matplotlib
        tkinter # matplotlib backend
        pillow # FIXME necessary for ranger image preview with kitty
      ] ++ optionals cfg.full [
      ]))
      ncdu # where is my space gone?
      translate-shell # translate
      unar
      nix-index
      tldr # quick usage examples
      mpv # audio and video player
      yt-dlp # media downloader (not just youtube)
      ffmpeg # cli media editor
      ncmpcpp # tui mpd music player
      wget
      zathura # minimal pdf viewer with vim contorls
      trash-cli # gentle rm replacement
      firejail # sandboxing
      httpie # cli http client
      eza # "modern" ls replacement
      fd # "modern" find replacement
      psmisc # `killall` command
      khard # calendar
      speedtest-cli # connection speed test
      fasd # cli navigation
      mpd
      mpc # mpd cli client
      jq # cli json handling
      pass # password manager
      nixpkgs-review # reviewing nix PRs
      sshfs # mount dirs from other machines
      # TODO
      # highlight
      # sshfs-fuse
      # xsel
      # ssh-ident
      # moreutils
      home-manager
      sbt # scala build manager, needed for university lecture
      source-code-pro # needed for gui neovim (FIXME)
      direnv # directory specific environments (used by lorri)
      bat # "cat" clone in rust with some nice additional features
    ] ++ (optionals cfg.full [
      # to find "offenders":
      # nix-store -q --requisites $( home-manager build ) | while read line; do du -hs "$line"; done | uniq | sort -h
      pandoc # convert between markup formats (pandoc -> ghc -> ~1.4G space)
      texlive.combined.scheme-full # latex
      # https://github.com/NixOS/nixpkgs/issues/92518
      # sageWithDoc # math software
    ]) ++ (optionals cfg.graphical [
      xclip # x11 clipboard management
      kdePackages.okular # feature-full pdf viewer
      # handwritten notes and pdf annotations
      (pkgs.symlinkJoin {
        # xournalpp with the workaround from [1]
        # [1] https://github.com/NixOS/nixpkgs/issues/163107#issuecomment-1100569484
        name = "xournalpp";
        paths = [pkgs.xournalpp];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          for binary in $out/bin/*; do
            wrapProgram "$binary" --prefix XDG_DATA_DIRS : '${pkgs.adwaita-icon-theme}/share:${pkgs.shared-mime-info}/share'
          done
        '';
      })
      gimp # image editing
      telegram-desktop # telegram chat
      spotify # music
      scrot # screenshots
      evince # more fully featured (and bloated) pdf viewer
      pavucontrol # volume
      sxiv # image viewer
      xcape # keyboard management
      xdotool # x automation
      chromium-widevine # fallback browser
      autorandr
      libnotify # notify-send
      xorg.xbacklight
      wireshark # network sniffing
      # TODO add simple wrapper that sets XDG_DESKTOP_DIR="$HOME/
      # https://bugzilla.mozilla.org/show_bug.cgi?id=1082717
      firefox
    ]);

    home.sessionVariables = {
      # Enable touchscreen scrolling for firefox
      "MOZ_USE_XINPUT2" = 1;
    };


    # Set up virt-manager to connect to qemu/kvm by default.
    # https://nixos.wiki/wiki/Virt-manager
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
      "org/virt-manager/virt-manager/details" = {
        show-toolbar = false; # No toolbar in VM view.
      };
      "org/virt-manager/virt-manager/vms/56642324e11d4801994836e4dd455202" = {
        resize-guest = 1; # Resize guest to fit window
      };
    };

    fonts.fontconfig.enable = true;

    # (Incomplete) replacement for wingdings from wine, "WineWingdings".
    # Required e.g. to render powerpoint online bullet points.
    # https://wiki.winehq.org/Create_Fonts#Truetype_Fonts
    home.file.".local/share/fonts/wingding.ttf".source = pkgs.fetchurl {
      url = "https://github.com/wine-mirror/wine/raw/02876a4b1320a1ee03b04c264fe31ccf6ec06d1c/fonts/wingding.ttf";
      hash = "sha256-z1eEtT42Xs+tFmG4sj0TPv+h07VPt6URN8ipVI8NsI4=";
    };

    # Adjust randr configuration when monitors are (un)plugged
    programs.autorandr.enable = true;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = "nvim-qt.desktop";
        "text/markdown" = "nvim-qt.desktop";
        "application/pdf" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "x-scheme-handler/ftp" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/tg" = "telegramdesktop.desktop";
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      # work around https://github.com/rycee/home-manager/issues/908
      extraConfig = ''
        pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry
      '';
      # defaultCacheTtl = 86400;
      # allow-loopback-pinentry
      # defaultCacheTtlSsh = TODO;
    };

    # services.mbsync.enable = TODO

    # services.polybar = TODO

    # services.screen-locker = TODO

    # project-specific nix-envs with direnv and good caching support
    services.lorri.enable = true;
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    nixpkgs.config = {
      allowUnfreePredicate = (pkg: elem (pkg.pname or (builtins.parseDrvName pkg.name).name) [
        # unfree whitelist
        "spotify"
        "copilot.vim"
        "spotify-unwrapped"
        "steam-runtime" # not actually used, but needed by steam-run

        # For chromium-widevine
        "chromium-unwrapped"
        "chromium"
        "widevine-cdm"
      ]);
      permittedInsecurePackages = [
        "zotero-6.0.27"
        "electron-24.8.6"
      ];
      firefox = {
        enableTridactylNative = true;
      };
    };

    programs.zsh = {
      enable = true;
      initExtra = (builtins.readFile ../zsh/.zshrc) +
      # temporary workaround for https://github.com/NixOS/nixpkgs/issues/45662#issuecomment-453253372
      ''
        export GI_TYPELIB_PATH=${lib.makeSearchPath "lib/girepository-1.0" (with pkgs; [
          gtk3
          pango.out
          gdk-pixbuf
          librsvg
          atk
        ])}
        export GDK_PIXBUF_MODULE_FILE="$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)"
        export XDG_DESKTOP_DIR="$HOME/Downloads" # because firefox creates this on start
      '';
      shellAliases = {
        # use ssh-ident to start ssh-agent as necessary
        ssh = "BINARY_SSH=${pkgs.openssh}/bin/ssh ${pkgs.ssh-ident}/bin/ssh-ident";
        scp = "BINARY_SSH=${pkgs.openssh}/bin/scp ${pkgs.ssh-ident}/bin/ssh-ident";
        rsync = "BINARY_SSH=${pkgs.rsync}/bin/rsync ${pkgs.ssh-ident}/bin/ssh-ident";
        cat = "${pkgs.bat}/bin/bat";
        # privacy / security / when my addons break something
      } // (
        if (cfg.full) then {
          fx = "${pkgs.firefox}/bin/firefox --new-instance --profile \"$(mktemp -d)\"";
          cx = "${chromium-widevine}/bin/chromium --user-data-dir=\"$(mktemp -d)\"";
        } else {}
      );
    };

    programs.bat = {
      enable = true;
      config.theme = "ansi";
    };

    programs.fish = {
      enable = true;
      shellAliases = {
        cat = "${pkgs.bat}/bin/bat";
        tp = "${pkgs.trash-cli}/bin/trash-put";
      };
      shellInit = ''
        export EDITOR=nvim
      '';
      plugins = [
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
            sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
          };
        }
      ];
      interactiveShellInit = ''
        set -l nix_shell_info (
          if test -n "$IN_NIX_SHELL"
            echo -n "<nix-shell> "
          end
        )
        echo -n -s "$nix_shell_info ~>"
      '';
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      newSession = true;
      extraConfig = ''
        set -g mouse on
      '';
    };

    xdg.enable = true;
    # make the sage colorscheme readable
    home.file.".sage/init.sage".text = ''
      %colors Linux
    '';

    xdg.configFile."sxhkd/sxhkdrc".source = ../sxhkd/.config/sxhkd/sxhkdrc;

    # TODO bag script

    services.dunst = {
      # TODO
      enable = cfg.graphical;
    };
    xdg.configFile."mpv" = {
      source = ../mpv/.config/mpv;
      recursive = true;
    };

    # services.gpg-agent = TODO
    xdg.configFile."dunst/dunstrc".source = ../dunst/.config/dunst/dunstrc;
    xdg.dataFile."applications/element.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${chromium-widevine}/bin/chromium --class 'Element' --app=https://app.element.io
      Name=Element messenger
    '';
    xdg.dataFile."applications/chatgpt.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${chromium-widevine}/bin/chromium --user-data-dir=.config/chromium/chatgpt --class 'ChatGPT' --app=https://chat.openai.com/
      Name=ChatGPT
    '';
    xdg.dataFile."applications/figma.desktop".text = makeChromiumDesktopApp "Figma" "https://www.figma.com/" "";
    xdg.dataFile."applications/brain.fm.desktop".text = makeChromiumDesktopApp "Brain.fm" "https://www.brain.fm/app" "";
    xdg.dataFile."applications/gemini.desktop".text = makeChromiumDesktopApp "Gemini" "https://gemini.google.com/app" "";
    xdg.dataFile."applications/aistudio.desktop".text = makeChromiumDesktopApp "Google AI Studio" "https://aistudio.google.com/prompts/new_chat" "";
    xdg.dataFile."applications/perplexity.desktop".text = makeChromiumDesktopApp "Perplexity" "https://www.perplexity.ai/" "";
    xdg.dataFile."applications/webwhiteboard.desktop".text = makeChromiumDesktopApp "Web Whiteboard" "https://webwhiteboard.com/" "--user-data-dir=/tmp/chromium-webwhiteboard";
    xdg.dataFile."applications/ticktick.desktop".text = makeChromiumDesktopApp "TickTick" "https://ticktick.com/webapp/" "";
    xdg.dataFile."applications/openrouter_chat.desktop".text = makeChromiumDesktopApp "OpenRouter Chat" "https://www.openrouter.ai/chat" "";
    xdg.dataFile."applications/notion.desktop".text = makeChromiumDesktopApp "Notion" "https://www.notion.so/" "";
    xdg.dataFile."applications/readwise_reader.desktop".text = makeChromiumDesktopApp "Readwise Reader" "https://read.readwise.io/home" "";
    xdg.dataFile."applications/readwise_feed.desktop".text = makeChromiumDesktopApp "Readwise Feed" "https://read.readwise.io/feed" "";
    xdg.dataFile."applications/claude.desktop".text = makeChromiumDesktopApp "Claude" "https://claude.ai/" "";
    xdg.dataFile."applications/google-calendar.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${chromium-widevine}/bin/chromium --class 'Google Calendar' --app=https://calendar.google.com
      Name=Google Calendar
    '';
    xdg.dataFile."applications/slack-kiml.desktop".text = makeChromiumDesktopApp "Slack KIML" "https://kiml-workspace.slack.com/" "";
    xdg.dataFile."applications/wandb.desktop".text = makeChromiumDesktopApp "Wandb" "https://wandb.ai" "";
    xdg.dataFile."applications/overleaf.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${chromium-widevine}/bin/chromium --class 'Overleaf' --app=https://overleaf.com/
      Name=Overleaf
    '';
    xdg.dataFile."applications/virt-manager_rdpwindows.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${pkgs.virt-manager}/bin/virt-manager --connect 'qemu:///system' --show-domain-console 'RDPWindows'
      Name=RDPWindows VM
    '';
    xdg.dataFile."applications/emacs-current-week.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${
        pkgs.writeScript "desktopexec.sh" ''
          #!${pkgs.bash}/bin/bash
          monday_iso="$( ${pkgs.python3}/bin/python -c "from datetime import date, timedelta; today = date.today(); monday = today - timedelta(days=today.weekday()); print(monday.isoformat())" )"
          ${pkgs.emacs}/bin/emacsclient -c -e "(org-roam-node-open-by-title \"week-$monday_iso\")"
        ''
      }
      Name=Emacs Org Roam Current Week
    '';
    xdg.dataFile."applications/emacs-next-week.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${
        pkgs.writeScript "desktopexec.sh" ''
          #!${pkgs.bash}/bin/bash
          monday_iso="$( ${pkgs.python3}/bin/python -c "from datetime import date, timedelta; today = date.today(); monday = today + timedelta(days=7 - today.weekday()); print(monday.isoformat())" )"
          ${pkgs.emacs}/bin/emacsclient -c -e "(org-roam-node-open-by-title \"week-$monday_iso\")"
        ''
      }
      Name=Emacs Org Roam Next Week
    '';
    xdg.dataFile."applications/emacs-inbox.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${pkgs.emacs}/bin/emacsclient -c -e "(org-roam-node-open-by-title \"inbox\")"
      Name=Emacs Org Roam Inbox
    '';

    home.file.".latexmkrc".text = ''
      # no interaction, enable synctex for vimtex integratoin
      $pdflatex = "pdflatex -synctex=1 -interaction=nonstopmode -halt-on-error %O %S";

      $pdf_previewer = 'start zathura';
      $pdf_mode = 1; # build pdf by default
      $failure_cmd = 'echo $"\a"; latexmk -C' # ring bell
    '';

    services.syncthing = {
      # TODO add config
      enable = true;
    };
    # Wrap syncthing with various commands to keep its resource usage low.
    systemd.user.services.syncthing.Service.ExecStart = pkgs.lib.mkForce (concatStringsSep " " [
      "${pkgs.coreutils}/bin/env GOMAXPROCS=1" # only one core (https://docs.syncthing.net/users/faq.html#why-does-it-use-so-much-cpu)
      "${pkgs.coreutils}/bin/nice --adjustment=19" # minimum scheduling priority
      "${pkgs.util-linux}/bin/ionice --class 2 --classdata 7" # "best effort" io scheduling with lowest priority
      "${pkgs.syncthing}/bin/syncthing -no-browser -no-restart -logflags=0"
    ]);

    xdg.configFile."tridactyl/tridactylrc".source = ../tridactyl/.config/tridactyl/tridactylrc;

    # hide mouse cursor when not moving
    services.unclutter = {
      enable = cfg.graphical;
    };

    systemd.user.services.xautolock = {
      Unit = {
        Description = "Lock screen on inactivity";
        After = [ "graphical-session-pre.target" ];
      };

      Service = {
        # FIXME script path
        ExecStart = ''
          ${pkgs.xautolock}/bin/xautolock \
            -detectsleep \
            -time 180 \
            -locker /home/timo/bin/lock \
            -notify 60 \
            -notifier '${pkgs.libnotify}/bin/notify-send --urgency=low "The screen will lock in 60s"' \
            -noclose
        '';
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    systemd.user.services.ovmtunnel-43800 = {
      Unit = {
        Description = "OVM tunnel (port 43800)";
        After="network.target";
      };

      Service = {
        Type="simple";
        Restart="on-failure";
        RestartSec=1;
        ExecStart = ''
            ${pkgs.openssh}/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=Yes -i ~/.ssh/tunnel-auth -L 43800:localhost:43800 tunnel@ovm -N -T
        '';
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    systemd.user.services.ovmtunnel-53800 = {
      Unit = {
        Description = "OVM tunnel (port 53800)";
        After="network.target";
      };

      Service = {
        Type="simple";
        Restart="on-failure";
        RestartSec=1;
        ExecStart = ''
            ${pkgs.openssh}/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=Yes -i ~/.ssh/tunnel-auth -L 53800:localhost:53800 tunnel@ovm -N -T
        '';
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.keyboard.layout = "de";

    # TODO udiskie, unclutter, xscreensaver

    programs.command-not-found.enable = true;

    # TODO try skim instead
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      changeDirWidgetCommand = "bash -c 'fasd -ld; fd --hidden --follow --no-ignore-vcs --type d'"; # Alt-C
      changeDirWidgetOptions = [ "--ansi" "--preview 'tree -C {} | head -200'" ];
      defaultCommand = "fd --type f";
      fileWidgetCommand = "bash -c 'fasd -l; fd --color=always --hidden --follow --no-ignore-vcs'";
      # try skim instead
      fileWidgetOptions = [ "--ansi" ];
      # defaultOptions = [ "--height 40%" "--border" ]
    };

    # programs.home-manager.enable = true;

    programs.htop = {
      enable = true;
      settings = {
        highlight_base_name = true;
        show_program_path = false;
        tree_view = true;
        sort_key = "PERCENT_MEM"; # usually the bottleneck
      };
    };

    # Configure touchegg. Note that the touchegg daemon is not managed by
    # home-manager, but by the system configuration. This config will only have
    # an effect if touchegg is running.
    home.file.".config/touchegg/touchegg.conf".text = ''
      <touchégg>

        <settings>
          <property name="animation_delay">150</property>
          <property name="action_execute_threshold">20</property>
          <property name="color">auto</property>
          <property name="borderColor">auto</property>
        </settings>

        <!--
          Global (application-independent) configuration
        -->
        <application name="All">
          <!--
            Right-click with two fingers
          -->
          <gesture type="TAP" fingers="2">
            <action type="MOUSE_CLICK">
              <button>3</button>
              <on>begin</on>
            </action>
          </gesture>
        </application>

      </touchégg>
    '';

    programs.rofi.enable = cfg.graphical;

    # programs.ssh.enable = true; TODO

    # programs.termite.enable = true; #TODO

    xsession.initExtra = optionalString cfg.graphical ''
      # no monitor timeout (handled by xautolock)
      ${pkgs.xorg.xset}/bin/xset s off -dpms
    '';

    # Needed for startx
    home.file.".xinitrc".text = ''
      exec ~/.xsession
    '';
  };
}
