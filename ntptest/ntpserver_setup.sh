#!/bin/bash


 # ntpserver_setup.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


echo "Stopping NTP service";
/etc/init.d/ntpd stop;

echo "Backing up /etc/ntp.conf";
mv /etc/ntp.conf /etc/ntp.conf.bak;
mkdir /var/log/ntpstats;

echo "Creating a ntp server configuration";
cp ntpserver.conf /etc/ntp.conf;
cp leap-seconds.list /var/log;

echo "Setting date to Jun 30 23:00:00 UTC 2015";
date -s "Jun 30 23:00:00 UTC 2015";

echo "Starting NTP service";
/etc/init.d/ntpd start;

if [ $? -ne 0 ]; then
    echo "Failed to start ntp service";
    exit 1;
fi

echo "ntp local server setup complete";
exit 0;
