#!/bin/bash
#
# Based on getperf.sh
#	v0.1 - 2025-09-12 - Ivan Lyanguzov
# usage:  getperf.sh switch_serial switch_ip &

# Set needed variables for generation
DAY=`date +"%Y.%m.%d"`
DATE=`date +"%Y%m%d.%H%M"`

# Get ODR config
. $HOME/.config/odr/odr.conf

# System Serial of the Brocade switch to collect for
switch=$1

# IP of the Brocade switch to collect for
ip=$2

# Workdir
workdir="$DATA/$DAY/$switch"
# Create if not exists
test -d "$workdir" || mkdir -p $workdir
cd $workdir

# Directory for perf data - B
perfdir=PerfData.$switch.$DATE
mkdir $perfdir

# Port stats
CMD="portperfshow -tx -rx -t $DELAY"
echo -n "$CMD *** " > $perfdir/portperf.out.$DATE 2>&1
$CLI $ip date >> $perfdir/portperf.out.$DATE 2>&1
screen -dmS $switch -L -Logfile $perfdir/portperf.out.$DATE timeout $((DELAY * ITER)) $CLI -t $ip $CMD
sleep $((DELAY * ITER))

# Get switch config
datetime=`date +"%Y-%m-%d-%H%M"`
$HOME/.local/bin/getconfig-brocade.sh $ip 2>&1 > config-$switch-$DAY-$datetime

# Pack data
tar -cjf ${perfdir}.tbz2 $perfdir config-$switch-$DAY-$datetime
tarRC=$?

if [ $tarRC -eq 0 ]
then
	rm -rf $perfdir
	rm config-$switch-$DAY-$datetime
else
	logger "Archive ${perfdir}.tbz2 return error. Data removed anyway"
	rm -rf $perfdir
	rm config-$switch-$DAY-$datetime
fi
