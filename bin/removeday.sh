#!/bin/bash

. $HOME/.config/odr/odr.conf

j=`date "+%s"`
e=`echo "$j-($REMOVE*24*3600)" | bc -l`
l=`date -d @"$e" "+%F" | sed -e "s/-/./g"`

if [ -d "$DATA/$l" ]
then
        logger "Remove $REMOVE days old directory $l"
        rm -rf $DATA/$l
fi
