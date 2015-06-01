#!/bin/sh
# Gets the network info to show it in a bar

# Obtain the info
bwm=$(bwm-ng -I eth0 -T avg -u bytes -o csv -c 1)¬
# Parse it
IFS=';'
set $bwm
unix_timestamp=$1
iface_name=$2
bytes_out=$3
bytes_in=$4
bytes_total=$5
packets_out=$6
packets_total=$7
errors_out=$8
errors_in=$9

#kbtotal=$(expr $bytes_total / 1024)

echo "$bytes_total"
