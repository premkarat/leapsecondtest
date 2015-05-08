#!/bin/bash


 # mpstat.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


# Cleanup any existing logs
rm -rf logs/dmesg.log > /dev/null 2>&1
# Logging date
echo "Log generated on `date`" >> logs/dmesg.log
echo "*********************************************" >> logs/dmesg.log

while true; 
do
  dmesg -c >> logs/dmesg.log 2>&1;
  sleep 30s; 
done;
