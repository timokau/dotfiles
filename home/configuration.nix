{ config, pkgs, lib, ... }:
let
  cfg = config.home;
in
with lib; {
  imports = [
    ./neovim.nix # editor
    ./taskwarrior.nix # todo list and task management
    ./newsboat.nix # rss reader
    ./git.nix
    ./r.nix
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
  };

  config = {
    herbstluftwm.enable = cfg.graphical;
    kitty.enable = cfg.graphical;
    redshift.enable = cfg.graphical;

    # only tools I use directly
    # tools used in scripts should be listed somewhere else
    home.packages = with pkgs; [
      skim # fzf clone in rust
      vagrant # VM management
      moreutils # usefull stuff like `vidir` bulk renaming
      ltrace # trace library calls
      pdftk # cutting and rotating pdfs
      gdb
      tmux
      libreoffice
      loc # SLOC language summary
      wireshark # network sniffing
      htop # system monitoring
      pdfgrep # search through pdfs
      imagemagick # cli image editing
      # for quick python experiments
      (python3.withPackages (pkgs: with pkgs; [
        # tensorflow # machine learning (currently not available with python 3.7)
        requests # http
        ipython # better interactive python
        numpy # number squashing
        networkx # graphs
        # graph-tool # more graphs
        matplotlib
        tkinter # matplotlib backend
        pygraphviz
      ]))
      (python2.buildEnv.override {
        extraLibs = with python2.pkgs; [
          tensorflow
          jupyter_core
          jupyter_client
          jupytext # edit jupyter notebooks in vim like regular python scripts
          notebook # jupyter
          tkinter # matplotlib backend
          matplotlib # plotting
          numpy
          requests
          ipython
        ];
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
      beets # music library manager
      ncmpcpp # tui mpd music player
      wget
      zathura # minimal pdf viewer with vim contorls
      pandoc # convert between markup formats
      texlive.combined.scheme-full # latex
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
      # TODO
      # highlight
      # sshfs-fuse
      # xsel
      # ssh-ident
      # moreutils
      home-manager
      sageWithDoc # math software
      retdec # decompiler
      radare2 # reverse engineering
    ] ++ (optionals cfg.graphical [
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
    ]);

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


    programs.firefox = {
      # TODO addons
      enable = true;
    };

    programs.zsh = {
      enable = true;
      initExtra = builtins.readFile ../zsh/.zshrc;
      shellAliases = {
        # use ssh-ident to start ssh-agent as necessary
        ssh = "BINARY_SSH=${pkgs.openssh}/bin/ssh ${pkgs.ssh-ident}/bin/ssh-ident";
        scp = "BINARY_SSH=${pkgs.openssh}/bin/scp ${pkgs.ssh-ident}/bin/ssh-ident";
        rsync = "BINARY_SSH=${pkgs.rsync}/bin/rsync ${pkgs.ssh-ident}/bin/ssh-ident";
      };
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
    xdg.dataFile."applications/riot.desktop".text = optionalString cfg.graphical ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec=${pkgs.chromium}/bin/chromium --class 'Riot' --app=https://riot.im/app
      Name=Riot messenger
    '';

    services.syncthing = {
      # TODO add config
      enable = true;
    };

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
        ExecStart = ~/bin/keyboardconfig;
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

    xsession.initExtra = ''
      # no monitor timeout (handled by xautolock)
      ${pkgs.xorg.xset}/bin/xset s off -dpms
    '';
  };
}
