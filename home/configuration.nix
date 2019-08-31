{ config, pkgs, lib, ... }:
let
  cfg = config.home;
in
  # TODO cleanup services
  # fd --no-ignore --changed-before 7d . ~/.cache --exec rm -f {}
  # fd --no-ignore --changed-before 1d --type f --type e . ~/.config --exec trash-put {}
  # TODO something similar .local?
with lib; {
  imports = [
    ./neovim.nix # editor
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

    # only tools I use directly
    # tools used in scripts should be listed somewhere else
    home.packages = let
      nix-bisect = pkgs.python3.pkgs.buildPythonPackage rec {
        pname = "nix-bisect";
        version = "0.1.0";
        # src = lib.cleanSource /home/timo/repos/nix-bisect;
        src = pkgs.fetchFromGitHub {
          owner = "timokau";
          repo = "nix-bisect";
          rev = "v${version}";
          sha256 = "1da3ik7hc9ds9kdf871hyy1khijw4q4zyq32hhx3pnwgadbh7d1v";
        };
      };
    in with pkgs; [
      pdfpc # latex beamer presentations
      entr # run command on file changes (nicer interface than inotify)
      skim # fzf clone in rust
      vagrant # VM management
      moreutils # usefull stuff like `vidir` bulk renaming
      ltrace # trace library calls
      gdb
      brightnessctl # controlling brightness on my laptop
      tmux
      loc # SLOC language summary
      htop # system monitoring
      pdfgrep # search through pdfs
      imagemagick # cli image editing
      superTuxKart # casual gaming
      graphviz # for pycallgraph, TODO add as upstream dependency
      dot2tex # graphviz <-> latex
      gnuplot # plot generation in latex
      # for quick python experiments
      (python3.withPackages (pkgs: with pkgs; [
        nix-bisect # bisect nix packages
        # rl algorithms
        (baselines.overrideAttrs (attrs: {
          # adds graph_nets support, see https://github.com/openai/baselines/pull/931
          src = fetchFromGitHub {
            owner = "timokau";
            repo = "baselines";
            sha256 = "1hf45d7p9aqqa7pnp6kqm2an5hgjv27jgy1whkzn1rppn6a8qbi9";
            rev = "c80ac03eb585766b422944ef5b900f9037fe725d";
          };
          patches = []; # included upstream
          # not needed for my purposes
          preBuild = ''
            sed -ie '/opencv-python/d' setup.py
          '';
        }))
        multiprocess # multiprocessing with better pickling
        psutil # process information for load balancing
        black # python formatting
        joblib # easy parallelization
        pycallgraph # profiling
        PyGithub
        notmuch # notmuch python api to sort mails
        tensorflow # machine learning
        graph_nets # neural graph networks with tensorflow
        pandas # data structures for data analysis
        pip
        pytest
        # TODO for some reason it is necessary to install this into the
        # environment in order for it to work properly (with imports) in
        # neovim
        pylint
        requests # http
        ipython # better interactive python
        numpy # number squashing
        networkx # graphs
        pydot # generating graph dot files in python
        matplotlib
        tkinter # matplotlib backend
        pygraphviz
        r2pipe
        pygobject3
        gobject-introspection
        pillow # FIXME necessary for ranger image preview with kitty
      ] ++ optionals cfg.full [
      ]))
      (python2.buildEnv.override {
        extraLibs = with python2.pkgs; [
          pillow # FIXME necessary for ranger image preview with kitty
          pytest
          jupyter_core
          jupyter_client
          jupytext # edit jupyter notebooks in vim like regular python scripts
          notebook # jupyter
          tkinter # matplotlib backend
          matplotlib # plotting
          numpy
          requests
          ipython
          pwntools
          r2pipe
        ] ++ (optionals cfg.full [
        ]);
        ignoreCollisions = true;
      })
      ncdu # where is my space gone?
      translate-shell # translate
      p7zip
      nix-index
      tldr # quick usage examples
      mpv # audio and video player
      youtube-dl # media downloader (not just youtube)
      ffmpeg # cli media editor
      ncmpcpp # tui mpd music player
      wget
      zathura # minimal pdf viewer with vim contorls
      trash-cli # gentle rm replacement
      firejail # sandboxing
      httpie # cli http client
      exa # "modern" ls replacement
      fd # "modern" find replacement
      psmisc # `killall` command
      khard # calendar
      speedtest-cli # connection speed test
      fasd # cli navigation
      mpd
      mpc_cli # mpd cli client
      jq # cli json handling
      pass # password manager
      nix-review # reviewing nix PRs
      sshfs # mount dirs from other machines
      # TODO
      # highlight
      # sshfs-fuse
      # xsel
      # ssh-ident
      # moreutils
      home-manager
      radare2 # reverse engineering
      source-code-pro # needed for gui neovim (FIXME)
    ] ++ (optionals cfg.full [
      # to find "offenders":
      # nix-store -q --requisites $( home-manager build ) | while read line; do du -hs "$line"; done | uniq | sort -h
      retdec # decompiler (~800mb)
      pandoc # convert between markup formats (pandoc -> ghc -> ~1.4G space)
      texlive.combined.scheme-full # latex
      sageWithDoc # math software
    ]) ++ (optionals cfg.graphical [
      libreoffice
      anki # flash cards
      xclip # x11 clipboard management
      okular # feature-full pdf viewer
      gimp # image editing
      tdesktop # telegram chat
      spotify # music
      kitty # terminal emulator
      digikam # picture management
      scrot # screenshots
      evince # more fully featured (and bloated) pdf viewer
      pavucontrol # volume
      sxiv # image viewer
      calibre # ebook management
      xcape # keyboard management
      rofi # launcher
      xdotool # x automation
      chromium # fallback browser
      autorandr
      libnotify # notify-send
      xorg.xbacklight
      radare2-cutter # radare gui
      wireshark # network sniffing
      # TODO add simple wrapper that sets XDG_DESKTOP_DIR="$HOME/
      # https://bugzilla.mozilla.org/show_bug.cgi?id=1082717
      firefox
    ]);

    fonts.fontconfig.enable = true;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      # fallback is not working
      # extraConfig = ''
      #   pinentry-program /home/timo/pinentry
      # '';
      # defaultCacheTtl = 86400;
      # allow-loopback-pinentry
      # defaultCacheTtlSsh = TODO;
    };

    # services.mbsync.enable = TODO

    # services.polybar = TODO

    # services.screen-locker = TODO


    nixpkgs.config = {
      allowUnfreePredicate = (pkg: elem (builtins.parseDrvName pkg.name).name [
        # unfree whitelist
        "spotify"
      ]);
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
          gdk_pixbuf
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
        # privacy / security / when my addons break something
      } // mkIf cfg.full {
        fx = "${pkgs.firefox}/bin/firefox --new-instance --profile \"$(mktemp -d)\"";
        cx = "${pkgs.chromium}/bin/chromium --user-data-dir=\"$(mktemp -d)\"";
      };
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
    xdg.configFile."mpv/scripts/find_subtitles.lua" = let
      script = builtins.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/directorscut82/find_subtitles/8508fb53cab32e8500deb0838dd84797acbd37ed/find_subtitles.lua";
        sha256 = "0vqkiscswzj2ah3bbq0pr3aymvyc67nlm2i2pp7ll5v747x5ybdq";
      });
    in {
      # would be easier to just include a copy in my dotfiles, but there is no
      # license...
      # alternative: https://github.com/vayan/autosub-mpv
      text = lib.replaceStrings [
        # Fix subliminal path
        "subliminal"
         # I don't want to *always* search for subtitles, just when triggered
        ''mp.register_event("start-file''
      ] [
        "${pkgs.python3.pkgs.subliminal}/bin/subliminal"
        "-- " # comment out
      ] script;
    };

    # services.gpg-agent = TODO
    xdg.configFile."dunst/dunstrc".source = ../dunst/.config/dunst/dunstrc;
    xdg.dataFile."applications/riot.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${pkgs.chromium}/bin/chromium --class 'Riot' --app=https://riot.im/app
      Name=Riot messenger
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
            -time 10 \
            -locker /home/timo/bin/lock \
            -notify 30 \
            -notifier '${pkgs.libnotify}/bin/notify-send --urgency=low "The screen will lock in 30s"' \
            -noclose
        '';
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.keyboardconfig = {
      Unit = {
        Description = "Adjust keyboard layout";
        After = [ "graphical-session-pre.target" ];
      };

      Service = {
        ExecStart = ''
          ${config.home.file."bin/keyboardconfig".source}
        '';
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # TODO udiskie, unclutter, xscreensaver

    programs.command-not-found.enable = true;

    programs.fzf.enable = true;

    # programs.home-manager.enable = true;

    programs.htop = {
      enable = true;
      highlightBaseName = true;
      showProgramPath = false;
      treeView = true;
      sortKey = "PERCENT_MEM"; # usually the bottleneck
    };

    programs.rofi.enable = cfg.graphical;

    # programs.ssh.enable = true; TODO

    # programs.termite.enable = true; #TODO

    xsession.initExtra = optionalString cfg.graphical ''
      # no monitor timeout (handled by xautolock)
      ${pkgs.xorg.xset}/bin/xset s off -dpms
    '';
  };
}
