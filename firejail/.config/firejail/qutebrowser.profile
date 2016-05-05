# Firejail profile for Mozilla Firefox (Iceweasel in Debian)

# blacklist
blacklist /mnt
blacklist /boot
blacklist /cdrom
blacklist /lost+found
blacklist /media
blacklist /proc
blacklist /srv
blacklist /usr/local
blacklist /tmp/*
blacklist /opt
blacklist /var/log
blacklist /var/spool
blacklist /var/tmp/*
blacklist /var/.updated
blacklist /sys/*
blacklist /.snapshots

# Whitelist
noblacklist ${HOME}/.mozilla
include /etc/firejail/disable-mgmt.inc
include /etc/firejail/disable-secret.inc
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
caps.drop all
seccomp
protocol unix,inet,inet6,netlink
netfilter
noroot
whitelist ~/data/downloads
whitelist ~/Downloads
whitelist ~/.config/qutebrowser
whitelist ~/.local/share/qutebrowser
# mpv is used for videos
whitelist ~/.config/mpv
whitelist ~/dotfiles/mpv

# private-dev
# private-etc alternatives,firefox,fonts,hosts,localtime,nsswitch.conf,resolv.conf,mpv,ssl,ca-certificates,pulse
