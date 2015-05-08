#!/bin/bash

 # setup.sh 
 #              by: Prem Karat (pkarat@mvista.com)
 #              (C) Copyright MontaVista 2015
 #              Licensed under the GPL
 #
 # WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 # RUN AT YOUR OWN RISK!


echo "Checking if bonnie++ is installed"
which bonnie++
if [ $? -ne 0 ] ; then
    echo "bonnie++ not installed"
    exit 1
fi

echo "Checking if hackbench is installed"
which hackbench 
if [ $? -ne 0 ] ; then
    echo "hackbench not installed"
    exit 1
fi

echo "Checking if cyclictest is installed"
which cyclictest 
if [ $? -ne 0 ] ; then
    echo "cyclictest not installed"
    exit 1
fi

echo "Checking if mpstat is installed"
which mpstat 
if [ $? -ne 0 ] ; then
    echo "mpstat not installed"
    exit 1
fi

echo "Building kernel test tools"
    cd kerntest
    make
    if [ $? -ne '0' ]; then
        echo 'Failed to kernel test tools'
        exit 1
    fi
    cd ..

echo "kernel test tools build complete"
echo
echo "Building futex stress tool"
    cd loadgen
    tar -xzvf futex-stress.tgz
    cd futex-stress
    make
    if [ $? -ne '0' ]; then
        echo 'Failed to build futex stress'
        exit 1
    fi
    cp futexstress ../
    echo "futex stress tool build complete"

exit 0
