#!/bin/bash
# Based on getconfig.sh
#	v0.1 - 2025-09-12 - Ivan Lyanguzov
# usage:  getconfig-brocade.sh switch_ip

# Get ODR config
. $HOME/.config/odr/odr.conf

# IP of the Brocade switch to collect for
ip=$1

commands=(
	"date" \
    "showipaddr" \
    "tsclockserver" \
    "dnsconfig --show" \
    "firmwareshow" \
    "licenseshow" \
    "license --show" \
    "chassisshow" \
	"switchshow" \
    "fabricshow" \
    "ag --modeshow" \
	"agshow --all" \
    "fdmishow" \
    "nsshow" \
    "defzone --show" \
    "cfgshow" \
    "zoneshow --validate" \
    "islshow" \
    "trunkshow" \
    "porttrunkarea --show all" \
    "porttrunkarea --show trunk" \
    "portcfgshow" \
    "sfpshow -health" \
    "sfpshow -all" \
    "porterrshow" \
    "sensorshow" \
    "userconfig --show -a" \
    "clihistory" \
    "errdump -a" \
)

#SN=`$CLI $ip chassisshow | grep "Serial Num" | awk '{print $NF}' | tail -n 1`

for i in ${!commands[*]}
do
	echo "### ${commands[$i]} ###"
	$CLI $ip ${commands[$i]} 2>&1
	echo
done
