{ config, pkgs, ... }:

let
  hostname = lib.fileContents ./hostname; # different file for each host, not version controlled
  homeipv6 = lib.fileContents ./homeipv6; # not version controlled
  isDesk = hostname == "desk";
  isPad = hostname == "pad";

  wireguard = {
    port = 51822;
    publicKey = {
      rpi = "gxkt8JC7F2ExSQkA41sY7e94qag693Cf9y3UiFOGQRE=";
      pad = "YoUI02AyBRNM7//UTzUlO90mCx7wHX+Jzxf2uaFR3gg=";
      desk = "d5KwIeKll+z5ZyAVRotC69RXuwM4VLwNtZoRoQEbTjo=";
    };
    ip = {
      rpi = "10.10.10.1";
      pad = "10.10.10.2";
      desk = "10.10.10.3";
      phone = "10.10.10.4";
    };
  };

  inherit (pkgs) lib;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.autorandr.enable = true;

  nix.useSandbox = true;
  nix.daemonIONiceLevel = 5;
  nix.daemonNiceLevel = 10;

  # install man pages
  environment.extraOutputsToInstall = [ "man" ];

  # only some administrative packages are installed at the system level
  environment.systemPackages = (with pkgs; [
    manpages
    # android-udev-rules
    # noto-fonts
    # dhcpcd
    acpi
    gnupg
    psmisc # killall
    git
    vim
    ranger
    tree
    htop
    rsync
    ripgrep
    home-manager # manage user configurations
  ]);


  # firejail needs to run setuid
  security.wrappers.firejail = {
    program = "firejail";
    source = "${pkgs.firejail.out}/bin/firejail";
    owner = "root";
    group = "root";
    setuid = true;
    setgid = true;
  };

  programs.adb.enable = true;
  # programs.command-not-found.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      source-code-pro
      inconsolata
      terminus_font
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/index.php/zswap
    "zswap.enabled" = 1;
    "kernel.sysrq" = 1; # enable "magic sysrq" to force OOM reaper
  };

  # mount /tmp in RAM. Don't do this on desk, as the machine tends to run out of ram.
  boot.tmpOnTmpfs = !isDesk;
  boot.cleanTmpDir = true;

  virtualisation.virtualbox.host = {
    enable = true;
    # enableExtensionPack = true; # unfree
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    ports = [ 2143 ];
  };

  # internationalisation properties
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  networking = {
    hostName = hostname;

    # use cloudflare dns which is uncensored (in contrast to that of my isp)
    nameservers = [ "1.1.1.1" ];
    networkmanager.insertNameservers = [ "1.1.1.1" ];

    # use networkmanager for easy wifi setup
    networkmanager.enable = true;

    # block all non-whitelisted connections
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22000 # syncthing sharing
        8200 # proxy
      ];
      allowedUDPPorts = [
        21027 # syncthing discovery
        wireguard.port
        22
        8200 # proxy
      ];
    };
  };

  powerManagement = {
    # support suspend-to-ram, save power
    enable = true;

    # log boots and wakes from suspend
    powerUpCommands = "date -Ih >> /var/log/power_up.log";

    # enable powertop autotuning when using the laptop
    powertop.enable = isPad;
  };

  services.snapper = {
    snapshotInterval = "hourly";
    configs.home = {
      subvolume = "/home";
      # snapshots are pretty much only used in case I accidentally delete or override something, which usually is caught pretty soon
      extraConfig = ''
        TIMELINE_CREATE=yes
        TIMELINE_CLEANUP=yes
        TIMELINE_LIMIT_HOURLY=16
        TIMELINE_LIMIT_DAILY=5
        TIMELINE_LIMIT_WEEKLY=1
        TIMELINE_LIMIT_MONTHLY=1
        TIMELINE_LIMIT_YEARLY=0
      '';
    };
  };

  # TODO make it possible to set this dynamically on the laptop
  # services.logind.extraConfig = "HandleLidSwitch=ignore";

  networking.hosts = {
    # give names to devices in my home network
    "192.168.0.22" = [ "desk-local" ];
    "${wireguard.ip.desk}" = [ "desk" ];
    "192.168.0.38" = [ "rpi-local" ];
    "${wireguard.ip.rpi}" = [ "rpi" ];
    "${wireguard.ip.pad}" = [ "pad" ];
    "192.168.0.21" = [ "opo" ];
    "192.168.0.20" = [ "laptop" ];
    "192.168.0.26" = [ "kindle" ];
    "192.168.0.45" = [ "par" ];
    "192.168.0.1" = [ "rooter" ];
    "192.168.0.100" = [ "eb" ];
  };

  services.xserver = {
    dpi = if isPad then 120 else null;

    # Enable the X11 windowing system.
    enable = true;
    layout = "de";
    xkbOptions = "eurosign:e";
    displayManager = {
      # use sddm (KDE) for login
      sddm.enable = true;
      # job.preStart = "${pkgs.xorg.setxkbmap}/bin/setxkbmap de";
      # sddm.stopScript # executed when stopping the x server
      sessionCommands = "/home/timo/.xprofile"; # TODO setupCommands?
    };
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # scanner support
  hardware.sane.enable = true;
  hardware.brightnessctl.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # extraConfig = ''
    #   unload-module module-stream-restore
    # '';
  };

  # boot.extraModprobeConfig = ''
  #   options snd_hda_intel index=1,0
  # '';

  # necessary to generate /etc/zsh (so that users can use zsh as a login shell)
  programs.zsh.enable = true;

  # environment.variables = {
  #   EDITOR = "nvim";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.timo = {};
  users.users.timo = {
    isNormalUser = true;
    group = "timo";
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "scanner"
      "docker"
      "vboxusers"
      "wireshark"
      "video" # brightnessctl
    ];
    uid = 1000;
    shell = "${pkgs.zsh}/bin/zsh";
    # needs to be changed, default is for VMs
    initialPassword = "password";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = if isPad then "18.03" else "19.03";

  systemd.services.channelUpdate  = {
    description = "Updates the unstable channel";
    script = "${pkgs.nix.out}/bin/nix-channel --update";
    startAt = "daily";
    environment.HOME = "/root";
  };


  systemd.services.suspend = {
    description = "Suspend the computer";
    script = ''
      ${pkgs.libudev}/bin/systemctl suspend
    '';
  };

  system.autoUpgrade = {
    enable = true;
    dates = "daily";
  };

  # nix.buildMachines = [{
  #   hostName = "desk";
  #   sshKey = TODO;
  #   maxJobs = 4;
  #   systems = [
  #     "x86_64-linux"
  #     "x686-linux"
  #   ];
  #   speedFactor = 2;
  # }];

  # nix.requireSignedBinaryCaches = false;
  # nix.trustedUsers = [ "timo" ];
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "aarch64.nixos.community";
      maxJobs = 64;
      sshKey = "/root/id_aarch64-builder";
      sshUser = "timokau";
      system = "aarch64-linux";
      supportedFeatures = [ "big-parallel" ];
    }
  ];
  programs.ssh.knownHosts = {
    aarch64-community-builder = {
      hostNames = [ "aarch64.nixos.community" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUTz5i9u5H2FHNAmZJyoJfIGyUm/HfGhfwnc142L3ds";
    };
  };
  programs.ssh.extraConfig = ''
    Host aarch64-nix-community
      Hostname aarch64.nixos.community
      User timokau
      IdentityFile /root/id_aarch64-builder
  '';

  nix.optimise = {
    automatic = true;
    dates = [ "19:00" ];
  };

  nix.extraOptions = ''
    min-free = 2147483648 # automatically collect garbage when <2 GiB free
    max-free = 3221225472 # stop at 3 GiB
    max-silent-time = 1800
    builders-use-substitutes = true
  '';

  nix.buildCores = 0; # use all available CPUs
  nix.maxJobs = 4; # number of jobs (builds) in parallel

  # r8169 network driver sometimes fails to bring network back up after suspend.
  # Re-enabling it requires reboot. r8168 can be used instead for the networks
  # card and doesn't have that bug. r8169 needs to be blacklisted to make sure
  # r8168 is used.
  # This network card is used in my desktop pc.
  boot.extraModulePackages = with pkgs.linuxPackages; lib.optionals isDesk [
      r8168
  ];
  boot.blacklistedKernelModules = lib.optionals isDesk [
    "r8169"
  ];

  # configure static monitor setup on desk
  services.xserver.xrandrHeads = lib.optionals isDesk [
    {
      output = "HDMI-3";
      primary = true;
      monitorConfig = ''
        Option "Position" "2280 417"
        Option "PreferredMode" "1920x1080"
      '';
    }
    {
      output = "DisplayPort-3";
      monitorConfig = ''
        Option "Rotate" "left"
        Option "Position" "1080 70"
        Option "PreferredMode" "1920x1200"
      '';
    }
  ];

  services.xserver.libinput = {
    enable = isPad;
    disableWhileTyping = true;
    scrollButton = 2;
    scrollMethod = "twofinger";
  };

  # create a virtual homenet
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${wireguard.ip.${hostname}}/24" ];
    listenPort = wireguard.port;
    privateKeyFile = "/home/timo/wireguard-keys/private"; # FIXME location
    preSetup = ''
      # https://github.com/NixOS/nixpkgs/issues/30459
      # Try to access the DNS for up to 300s
      for i in {1..300}; do
        ${pkgs.iputils}/bin/ping -c1 '1.1.1.1' && break
        echo "Attempt $i: DNS still not available"
        sleep 1s
      done
    '';

    peers = [
      {
        publicKey = wireguard.publicKey.rpi;
        allowedIPs = [
          "${wireguard.ip.rpi}/32"
          "${wireguard.ip.pad}/32"
          "${wireguard.ip.desk}/32"
          "${wireguard.ip.phone}/32"
        ];
        # endpoint = "${dyndns}:${toString wireguard.port}";
        endpoint = "${homeipv6}:${toString wireguard.port}";
      }
    ];
  };
}
