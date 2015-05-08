#!/bin/bash


 # testkernleap.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # This script is a wrapper for invoking the leapsecond tests developed
 # by John Stultz from LKML. The source of all these files can be found
 # in https://github.com/johnstultz-work/timetests
 # leapcrash.c and leap-a-day.c
 # Please note that the leap-a-day.c has been modified to suit the testing
 # needs in a scalable manner
 #
 # Please note that leapbasic.c is a source file from AmadeusIT group from
 # https://github.com/AmadeusITGroup/NTP-Proxy but modified to fix a bug
 # https://github.com/AmadeusITGroup/NTP-Proxy/issues/7
 # The source is sls.c which is GPLv3 licensed.
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


# cleanup any existing testkernleap.log
rm -rf logs/testkernleap.log;
# Basic Leap Second Insertion/deletion test
echo "***************************************************" \
     | tee -a logs/testkernleap.log; 
echo "1. Testing for basic leap second insertion/deletion" \
     | tee -a logs/testkernleap.log;
echo "***************************************************" \
     | tee -a logs/testkernleap.log;
# Stop NTP service and clear dmesg before start of test
/etc/init.d/ntpd stop > /dev/null  2>&1;
dmesg -c > /dev/null 2>&1;
echo -e "\ta. Executing leapsecond insertion basic test" \
        | tee -a logs/testkernleap.log;
./leapbasic -d 10 -l add > /dev/null 2>&1;
./leapbasic -s | grep 'flag: add' > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo -e "\t\t[FAILED]: leap second flag not set to 'add'" \
            | tee -a logs/testkernleap.log;
    exit 1;
fi
echo -e "\t\t[PASSED]: kernel leap second flag set to add" \
        | tee -a logs/testkernleap.log;
echo -e "\t\t[LOG] sleeping for 15 seconds..." \
        | tee -a logs/testkernleap.log;
sleep 15s;
dmesg -c | grep 'Clock: inserting leap second 23:59:60 UTC' > /dev/null;
if [ $? -ne 0 ]; then
    echo -e "\t\t[FAILED]: fail to insert leap second" \
            | tee -a logs/testkernleap.log;
    exit 1;
fi
echo -e "\t\t[PASSED]: Leap second inserted in kernel" \
        | tee -a logs/testkernleap.log;

echo | tee -a logs/testkernleap.log;
echo -e "\tb. Executing leapsecond deletion basic test" \
        | tee -a logs/testkernleap.log;
./leapbasic -d 10 -l del > /dev/null 2>&1;
./leapbasic -s | grep 'flag: del' > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo -e "\t\t[FAILED]: leap second flag not set to del" \
            | tee -a logs/testkernleap.log;
    exit 1;
fi
echo -e "\t\t[PASSED]: kernel leap second flag set to del" \
        | tee -a logs/testkernleap.log;
echo -e "\t\t[LOG] Sleeping for 15 seconds..." \
        | tee -a logs/testkernleap.log;
sleep 15s;
dmesg -c | grep 'Clock: deleting leap second 23:59:59 UTC' > /dev/null;
if [ $? -ne 0 ]; then
    echo -e "\t\t[FAILED]: fail to delete leap second" \
            | tee -a logs/testkernleap.log;
    exit 1;
fi
echo -e  "\t\t[PASSED]: Leap second deleted in kernel" \
         | tee -a logs/testkernleap.log;
echo "Basic leap second insertion/deletion test completed" \
     | tee -a logs/testkernleap.log;

echo | tee -a logs/testkernleap.log;
echo "***************************************************" \
     | tee -a logs/testkernleap.log;
echo "2. Testing for leapsecond deadlock" \
     | tee -a logs/testkernleap.log;
echo "***************************************************" \
     | tee -a logs/testkernleap.log;
./leapcrash
echo "Leap second deadlock detection test completed" \
     | tee -a logs/testkernleap.log;

echo  | tee -a logs/testkernleap.log;
echo "***************************************************" \
     | tee -a logs/testkernleap.log;
echo "3. Testing for leapsecond stress" \
     | tee -a logs/testkernleap.log;
echo "***************************************************" \
     | tee -a logs/testkernleap.log;
dmesg -c  > /dev/null 2>&1;
echo -e "\t[LOG] Starting futexstress" | tee -a logs/testkernleap.log;
../loadgen/futexstress.sh &
echo -e "\t[LOG] Starting cyclictest" | tee -a logs/testkernleap.log;
../loadgen/cyclictest.sh &
echo -e "\t[LOG] Starting hackbench" | tee -a logs/testkernleap.log;
../loadgen/hackbench.sh &
echo -e "\t[LOG] Starting bonnie++" | tee -a logs/testkernleap.log;
../loadgen/bonnie++.sh &
echo -e "\t[LOG] Sleeping for 5 mins" | tee -a logs/testkernleap.log;
sleep 5m;
rm -rf logs/leapstress.log /dev/null 2>&1;
echo -e "\t[LOG] Executing leapstress for 10 iterations each for 10s" \
        | tee -a logs/testkernleap.log;
./leapstress -s 10 -i 10  >> logs/leapstress.log 2>&1;
echo -e "\t[LOG] Checking dmesg for leap second ins/del 5 times each" \
        | tee -a logs/testkernleap.log;
dmesg -c;
grep 'ERROR: hrtimer' logs/leapstress.log > /dev/null;
if [ $? -eq 0 ]; then
    echo -e "\t[FAILED]: hrtimer expiry detected" \
            | tee -a logs/testkernleap.log;
    cd ..;./cleanup.sh; cd kerntest;
    echo -e "\t[LOG] cleanup complete" | tee -a logs/testkernleap.log;
    exit 1;
fi
echo
echo -e "\t[PASSED]: hrtimer expiry not detected" \
        | tee -a logs/testkernleap.log;
grep 'Leap complete' logs/leapstress.log | wc -l | grep 10 > /dev/null;
if [ $? -ne 0 ]; then
    echo -e "\t[FAILED]: Leap Stress failed" \
            | tee -a logs/testkernleap.log;
    cd ..;./cleanup.sh; cd kerntest;
    echo -e "\t[LOG] cleanup complete" \
            | tee -a logs/testkernleap.log;
    exit 1;
fi
echo -e "\t[LOG] Leap stress logs available at logs/leapstress.log" \
        | tee -a logs/testkernleap.log;
echo -e "\t[PASSED]: Leap second stress" | tee -a logs/testkernleap.log;
echo | tee -a logs/testkernleap.log;
cd ..;./cleanup.sh; cd kerntest;
echo -e "\t[LOG] cleanup complete" | tee -a logs/testkernleap.log;
echo "Kernel leap second test completed" | tee -a logs/testkernleap.log;
exit 0;
