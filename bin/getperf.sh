#!/bin/bash
#
# file: getperf.sh
#
# usage:  getperf.sh array_name array_ip &
#
#	rev 1.0 - 02/14/2012 - Kelly Graham, few mods Mark Aring
#		- Updated variables and adds showtask, showvvcpg output
#	rev 1.1 - 03/12/2012 - Mark Aring, removed "-ni" options from
#		commands to keep timesamples consistent across dataset
#	rev 1.2	- 06/08/2012 - Mark Aring, added iteration variables for
#		large VLUN/PD configs to reduce file size and missed samples
#	rev 1.3	- 03/13/2013 - Mark Aring, added statrcvv collection to script
#	rev 1.4 - about 2017, Dmitry Lyanguzov, modify script to work
#		through ssh
#	rev 1.5 - 04 aug 2020, D. Lyanguzov, modify to use with external
#		config
#	rev 1.51 - 15 aug 2020, D. Lyanguzov, minor changes
#	rev 1.52 - 6 oct 2020, DL, add config to the archive
#

# Set needed variables for generation
#
DAY=`date +"%Y.%m.%d"`
DATE=`date +"%Y%m%d.%H%M"`

# Get config
. $HOME/odr.conf

# Get home
# Location of CLI executable file on SP
# P=/usr/bin/ssh
# P -> CLI

# System Serial of the Inserv to collect for - V
V=$1

# IP of the Inserv to collect for - J
J=$2

# Workdir
WD="$DATA/$DAY/$V"
# Create if not exists
test -d "$WD" || mkdir -p $WD
cd $WD

# Historical data...
# N -> ITER
# D -> DELAY
# M -> ITER
# C -> DELAY

# Directory for perf data - B
B=PerfAnalysis.$V.$DATE
mkdir $B

# Stat for vluns
 CMD="statvlun -rw -iter $ITER -d $DELAY"
 echo "$CMD ***" > $B/statvlun.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statvlun.out.$DATE 2>&1 &

# Stat for host ports
 CMD="statport -host -rw -iter $ITER -d $DELAY"
 echo "$CMD ***" > $B/statport-host.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statport-host.out.$DATE 2>&1 &

# Stat for disk ports
 CMD="statport -disk -rw -iter $ITER -d $DELAY"
 echo "$CMD ***" > $B/statport-disk.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statport-disk.out.$DATE 2>&1 &

# Stat cache usage
 CMD="statcmp -iter $ITER -d $DELAY"
 echo "CMD ***" > $B/statcmp.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statcmp.out.$DATE 2>&1 &

# Stat CPU
 CMD="statcpu -iter $ITER -d $DELAY"
 echo "$CMD ***" > $B/statcpu.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statcpu.out.$DATE 2>&1 &

# Stat physical disks
 CMD="statpd -rw -iter $ITER -d $DELAY -devinfo"
 echo "$CMD ***" > $B/statpd.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statpd.out.$DATE 2>&1 &

# Stat replica ports
 CMD="statport -rcfc -iter $ITER -d $DELAY"
 echo "$CMD ***" > $B/statport-rcfc.out.$DATE 2>&1
 $CLI $CLIUSER@$J $CMD >> $B/statport-rcfc.out.$DATE 2>&1 &

# Unused at this time
# CMD="statrcopy -iter $ITER -d $DELAY"
# echo "$CMD ***" > $B/statrcopy.out.$DATE 2>&1
# $CLI $CLIUSER@$J $CMD >> $B/statrcopy.out.$DATE 2>&1 &

#
# Wait for the stat commands will be finished
wait

#
# Get array config here
#
T=`date +"%Y-%m-%d-%H%M"`
$HOME/bin/getconfig.sh $J 2>&1 > config-$V-$DAY-$T

# Package up the data
tar -cjf ${B}.tbz2 $B config-$V-$DAY-$T
tarRC=$?

# Тут надо обговорить - что делаем, если архив не собрался.
#
if [ $tarRC -eq 0 ]
then
	rm -rf $B
	rm config-$V-$DAY-$T
else
	logger "Archive ${B}.tbz2 return error. Data removed anyway"
	rm -rf $B
	rm config-$V-$DAY-$T
fi
