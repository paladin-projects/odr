#!/bin/bash

. $HOME/.config/odr/odr.conf

l=`date --date="-$REMOVE day" +%Y.%M.%d`

if [ -d "$DATA/$l" ]
then
        logger "Remove $REMOVE days old directory $l"
        rm -rf $DATA/$l
fi
