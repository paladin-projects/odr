#!/bin/bash
# Based on getconfig.sh
#	v0.1 - 2025-09-12 - Ivan Lyanguzov
# usage:  getconfig-brocade.sh switch_ip

# Get ODR config
. $HOME/odr.conf

# IP of the Brocade switch to collect for
ip=$1

commands=("switchshow" \
"fdmishow" \
"nsshow" \
"licenseshow" \
"sfpshow" \
"sfpshow -all" \
"chassisshow")

SN=`$CLI $CLIUSER@$ip chassisshow | grep "Serial Num" | awk "{print $NF}" | tail -n 1`

for i in ${!commands[*]}
do
	echo "### ${commands[$i]} ###"
	$CLI $CLIUSER@$ip ${commands[$i]} 2>&1
	echo
done
