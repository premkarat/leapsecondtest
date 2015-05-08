#!/bin/bash


 # mpstat.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


# Cleanup any existing logs
rm -rf logs/mpstat.log > /dev/null 2>&1
# Logging date
echo "Log generated on `date`" >> logs/mpstat.log
echo "*********************************************" >> logs/mpstat.log

while true; 
do
  date >> logs/mpstat.log
  mpstat -P ON 300 >> logs/mpstat.log 2>&1;
  echo "-----------------------------------------------" >> logs/mpstat.log
done;
