#!/bin/bash


 # cleanup.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


killall hackbench.sh > /dev/null 2>&1
killall hackbench > /dev/null 2>&1
killall futexstress.sh > /dev/null 2>&1
killall futexstress > /dev/null 2>&1
killall bonnie++.sh > /dev/null 2>&1
killall bonnie++ > /dev/null 2>&1
killall cyclictest.sh > /dev/null 2>&1
killall cyclictest > /dev/null 2>&1
killall dmesg.sh > /dev/null 2>&1
killall mpstat.sh > /dev/null 2>&1
rm -rf loadgen/futexstress > /dev/null 2>&1
cd kerntest; make clean; cd ..
rm -rf kerntest/Bonnie* > /dev/null 2>&1
rm -rf ntptest/Bonnie* > /dev/null 2>&1
exit 0
