#!/bin/bash


 # hackbench.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


# Cleanup any existing logs
rm -rf logs/hackbench.log > /dev/null 2>&1
# Logging date
echo "Log generated on `date`" >> logs/hackbench.log
echo "*********************************************" >> logs/hackbench.log

while true 
do
    hackbench -l 10000 -T -g 4 >> logs/hackbench.log 2>&1
done
