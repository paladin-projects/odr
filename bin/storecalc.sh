#!/bin/bash

. $HOME/.config/odr/odr.conf

df -h | awk -v data=$DATAPOINT '
$6 == data {
  print "<p><pre>"
  print "FS mounted on " $6 " has " $4 " free"
  print "Used: " $5
  print "</pre></p>"
}' > $DATA/.storstat
