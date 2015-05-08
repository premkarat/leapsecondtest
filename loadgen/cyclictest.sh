#!/bin/bash

 # cyclictest.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


# Cleanup any existing logs
rm -rf logs/cyclictest.log > /dev/null 2>&1
# Logging date
echo "Log generated on `date`" >> logs/cyclictest.log
echo "*********************************************" >> logs/cyclictest.log

while true
do
    cyclictest -t -p 99 -n -m  >> logs/cyclictest.log 2>&1
done
