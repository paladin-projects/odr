#!/bin/bash
# Based on getconfig.sh
#	v0.1 - 2025-09-12 - Ivan Lyanguzov
# usage:  getconfig-brocade.sh switch_ip

# Get ODR config
. $HOME/.config/odr/odr.conf

# IP of the Brocade switch to collect for
ip=$1

commands=("switchshow" \
    "fabricshow" \
    "firmwareshow" \
    "fdmishow" \
    "nsshow" \
    "zone --validate" \
    "licenseshow" \
    "sfpshow" \
    "sfpshow -all" \
    "showipaddr" \
    "chassisshow")

#SN=`$CLI $ip chassisshow | grep "Serial Num" | awk '{print $NF}' | tail -n 1`

for i in ${!commands[*]}
do
	echo "### ${commands[$i]} ###"
	$CLI $ip ${commands[$i]} 2>&1
	echo
done
