#!/bin/bash

 # futexstress.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!
 # This futex stress is designed by Davidlohr Bueso and the stress tool
 # is available under https://github.com/davidlohr/futex-stress

# Cleanup any existing logs
rm -rf logs/futexstress.log > /dev/null 2>&1
# Logging date
echo "Log generated on `date`" >> logs/futexstress.log
echo "*********************************************" >> logs/futexstress.log

while true; 
do
  ../loadgen/futexstress >> logs/futexstress.log 2>&1;
done;
