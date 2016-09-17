#!/bin/bash


 # testntpleap.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


if [ -z $1 ]; then
    echo -e "\tNTP server not specified";
    echo -e "\tUsage: ./testnptleap.sh <ntp_server_ipaddr>";
    exit 1;
fi

server=$1;

# cleanup any existing testkernleap.log
rm -rf logs/testntpleap.log;

echo "***************************************************" \
     | tee -a logs/testntpleap.log;
echo "Testing for leap second insertion through NTP" \
     | tee -a logs/testntpleap.log;
echo "***************************************************" \
     | tee -a logs/testntpleap.log;

# Stopping NTP service and backing up /etc/ntp.conf
/etc/init.d/ntpd stop > /dev/null 2>&1;
mv /etc/ntp.conf /etc/ntp.conf.bak >/dev/null 2>&1;
mkdir /var/log/ntpstats > /dev/null 2>&1;
echo "statsdir /var/log/ntpstats/" >> /etc/ntp.conf;
echo "statistics loopstats" >> /etc/ntp.conf;
echo "filegen loopstats file loopstats type day enable" >> /etc/ntp.conf;
echo "server $server" >> /etc/ntp.conf;

# Setting date to Dec 31 23:00:00 UTC 2016
date -s "Dec 31 23:00:00 UTC 2016" > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo -e "\t[FAILED]: Failed to set date to Dec 31 23:00:00 2016" \
            | tee -a logs/testntpleap.log;
    mv /etc/ntp.conf.bak /etc/ntp.conf >/dev/null 2>&1;
    exit 1;
fi

# starting NTP service"
/etc/init.d/ntpd start > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo -e "\t[FAILED]: Failed to start ntp service" \
            | tee -a logs/testntpleap.log;
    mv /etc/ntp.conf.bak /etc/ntp.conf >/dev/null 2>&1;
    exit 1;
fi

ntpq -p  > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo -e "\t[FAILED]: Failed to query ntp server" \
            | tee -a logs/testntpleap.log;
    mv /etc/ntp.conf.bak /etc/ntp.conf >/dev/null 2>&1;
    exit 1;
fi

dmesg -c > /dev/null;
echo -e "\t[LOG] Sleeping for 30min for ntpclock to sync with server" \
        | tee -a logs/testntpleap.log;
sleep 30m;

ntpq -c rl | grep 'leap=01' > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo -e "\t[FAILED]: Leap second flag not enabled in ntp client" \
            | tee -a logs/testntpleap.log;
    mv /etc/ntp.conf.bak /etc/ntp.conf >/dev/null 2>&1;
    exit 1;
fi
echo -e "\t[PASSED]: Leap flag enabled in ntp client" \
        | tee -a logs/testntpleap.log;
# Collecting cpu stats"
../loadgen/mpstat.sh &
echo -e "\t[LOG] Starting futexstress" | tee -a logs/testntpleap.log;
../loadgen/futexstress.sh &
echo -e "\t[LOG] Starting cyclictest" | tee -a logs/testntpleap.log;
../loadgen/cyclictest.sh &
echo -e "\t[LOG] Starting hackbench" | tee -a logs/testntpleap.log;
../loadgen/hackbench.sh &
echo -e "\t[LOG] Starting bonnie++" | tee -a logs/testntpleap.log;
../loadgen/bonnie++.sh &
# Monitoring dmesg"
../loadgen/dmesg.sh &

echo -e "\t[LOG] Sleeping for 40mins...." | tee -a logs/testntpleap.log;
sleep 40m;

grep 'Clock: inserting leap second 23:59:60 UTC' logs/dmesg.log > /dev/null;
if [ $? -ne 0 ]; then
    echo -e "\t[FAILED]: NTP client failed to pass on leap second flag" \
            | tee -a logs/testntpleap.log;
    echo -e "\t[LOG] Test logs under logs/ directory" \
            | tee -a logs/testntpleap.log;
    echo -e "\t[LOG] Running cleanup.sh...." \
            | tee -a logs/testntpleap.log;
    mv /etc/ntp.conf.bak /etc/ntp.conf >/dev/null 2>&1;
    cd ..;./cleanup.sh; cd ntptest; 
    echo -e "\t[LOG] cleanup complete" | tee -a logs/testntpleap.log;
    exit 1;
fi
echo -e "\t[PASSED]: Leap second inserted in kernel" \
        | tee -a logs/testntpleap.log;
echo -e "\t[LOG] Check for hike in cpu usage..." \
        | tee -a logs/testntpleap.log;
echo | tee -a logs/testntpleap.log;
echo -e "***************************************************************" \
        | tee -a logs/testntpleap.log;
mpstat -P ON | tee -a logs/testntpleap.log;
echo -e "***************************************************************" \
        | tee -a logs/testntpleap.log;
mv /etc/ntp.conf.bak /etc/ntp.conf >/dev/null 2>&1;
cd ..;./cleanup.sh; cd ntptest; 
echo -e "\t[LOG] cleanup complete" | tee -a logs/testntpleap.log;
echo | tee -a logs/testntpleap.log;
echo -e "NTP leap second test completed" | tee -a logs/testntpleap.log;
exit 0;
