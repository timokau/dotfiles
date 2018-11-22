{ pkgs, ... }:
let
  unstable = import <unstable> { inherit (pkgs) config; };
  pkgs-unstable = import <pkgs-unstable> { inherit (pkgs) config; };
in
{
  imports = [
    ./home/neovim.nix # editor
    ./home/taskwarrior.nix # todo list and task management
    ./home/redshift.nix # shift screen light to red (away from blue) in the evening to tell the brain its night time
    ./home/newsboat.nix # rss reader
    ./home/herbstluftwm.nix # window manager
    ./home/git.nix
    ./home/r.nix
    ./home/ranger.nix # file manager
    ./home/mutt.nix # mail
    ./home/scripts.nix
  ];

  xsession.enable = true;
  # TODO add module
  xsession.windowManager.command = ''
    PATH="${pkgs.herbstluftwm}/bin:$PATH" herbstluftwm
  '';

  # only tools I use directly
  # tools used in scripts should be listed somewhere else
  home.packages = with pkgs; [
    moreutils # usefull stuff like `vidir` bulk renaming
    ltrace # trace library calls
    gparted # partitioning
    anki # flash cards
    pdftk # cutting and rotating pdfs
    gdb
    tmux
    libreoffice
    loc # SLOC language summary
    xclip # x11 clipboard management
    wireshark # network sniffing
    htop # system monitoring
    pdfgrep # search through pdfs
    okular # feature-full pdf viewer
    gimp # image editing
    imagemagick # cli image editing
    # for quick python experiments
    (python3.withPackages (pkgs: [
      pkgs.six
      pkgs.requests
    ]))
    (python2.withPackages (pkgs: with pkgs; [
      six
      requests
      rpy2
      ipython
    ]))
    ncdu # where is my space gone?
    translate-shell # translate
    p7zip
    nix-index
    tldr # quick usage examples
    tdesktop # telegram chat
    spotify # music
    kitty # terminal emulator
    digikam # picture management
    mpv # audio and video player
    youtube-dl # media downloader (not just youtube)
    ffmpeg # cli media editor
    beets # music library manager
    scrot # screenshots
    ncmpcpp # tui mpd music player
    wget
    zathura # minimal pdf viewer with vim contorls
    evince # more fully featured (and bloated) pdf viewer
    pandoc # convert between markup formats
    texlive.combined.scheme-full # latex
    trash-cli # gentle rm replacement
    nox # nix reviews
    radare2 # reverse engineering
    radare2-cutter # radare gui
    firejail # sandboxing
    pavucontrol # volume
    sxiv # image viewer
    httpie # cli http client
    calibre # ebook management
    exa # "modern" ls replacement
    fd # "modern" find replacement
    xcape # keyboard management
    psmisc # `killall` command
    khard # calendar
    speedtest-cli # connection speed test
    rofi # launcher
    xdotool # x automation
    fasd # cli navigation
    mpd
    mpc_cli # mpd cli client
    jq # cli json handling
    pass # password manager
    chromium # fallback browser
    autorandr
    libnotify # notify-send
    nix-review # reviewing nix PRs
    xorg.xmodmap # TODO use in keyboardconfig
    # TODO
    # highlight
    # sshfs-fuse
    # xsel
    # ssh-ident
    xorg.xbacklight
    # moreutils
  ] ++ (with unstable; [
    home-manager
    sageWithDoc # math software
    retdec # decompiler
  ]);

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
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
    initExtra = builtins.readFile ./zsh/.zshrc;
  };

  xdg.enable = true;
  # make the sage colorscheme readable
  home.file.".sage/init.sage".text = ''
    %colors Linux
  '';

  xdg.configFile."sxhkd/sxhkdrc".source = ./sxhkd/.config/sxhkd/sxhkdrc;

  # TODO bag script

  services.dunst = {
    # TODO
    enable = true;
  };
  xdg.configFile."mpv" = {
    source = ./mpv/.config/mpv;
    recursive = true;
  };
  # services.gpg-agent = TODO
  xdg.configFile."dunst/dunstrc".source = ./dunst/.config/dunst/dunstrc;
  xdg.dataFile."applications/riot.desktop".text = ''
    [Desktop Entry]
    Encoding=UTF-8
    Version=1.0
    Type=Application
    Terminal=false
    Exec=${pkgs.chromium}/bin/chromium --app=https://riot.im/app
    Name=Riot messenger
  '';

  services.syncthing = {
    # TODO add config
    enable = true;
  };

  # TODO udiskie, unclutter, xscreensaver

  # TODO window manager

  home.keyboard = {
    layout = "de";
    #options = [ # xkb options
      # "ctrl:swapcaps" # swap capslock with left ctrl
      #"caps:swapescape" # swap capslock with escape
      #"caps:ctrl_modifier" # caps lock is also a ctrl
      #"shift:breaks_caps" # shift cancels caps lock
    #];
  };

  programs.command-not-found.enable = true;

  programs.fzf.enable = true;

  # programs.home-manager.enable = true;

  programs.htop = {
    enable = true;
    highlightBaseName = true;
    showProgramPath = false;
    treeView = true;
  };

  programs.rofi.enable = true;

  # programs.ssh.enable = true; TODO

  # programs.termite.enable = true; #TODO

  home.file.".xprofile".text = ''
# This is better started by a systemd service, since it tends to crash on my laptop and needs
# to be automatically restarted.
keyboardconfig="$HOME/bin/keyboardconfig"
if [ -f "$keyboardconfig" ]; then
	bash "$keyboardconfig" & disown
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
	for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

userresources=$HOME/.Xresources
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# use the arrow cursor instead of the "x" cursor on the root window
xsetroot -cursor_name arrow &

# hide the mouse cursor after 2 seconds of idle time
unclutter -idle 2 &

# lock the screen after 15 minutes of inactivity
xautolock -time 10 \
    -locker "$HOME/bin/lock" \
    -notify 15 \
    -notifier 'notify-send --urgency=low "The screen will lock in 15s"' &

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcsll,secrets,ssh)
export SSH_AUTH_SOCK
syndaemon -d -k -i 1
  '';
}
