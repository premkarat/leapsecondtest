#!/bin/bash

 # bonnie++.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


# Cleanup any existing logs
rm -rf logs/bonnie.log > /dev/null 2>&1
# Logging date
echo "Log generated on `date`" >> logs/bonnie.log
echo "*********************************************" >> logs/bonnie.log

while true
do
    bonnie++ -u root >> logs/bonnie.log  2>&1;
done
