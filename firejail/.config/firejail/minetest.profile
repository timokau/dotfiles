# Very restrictive dasht profile
whitelist ~/.minetest/
include /etc/firejail/whitelist-common.inc
include /etc/firejail/disable-mgmt.inc
include /etc/firejail/disable-secret.inc
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
caps.drop all
seccomp
noroot

# network access
# protocol unix,inet,inet6,netlink
# netfilter

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

private-dev
private-etc alternatives,fonts,hosts,localtime,nsswitch.conf,resolv.conf,ssl,ca-certificates
