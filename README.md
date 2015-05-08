Linux leap second test

by: Prem Karat (pkarat@mvista.com)

(C) Copyright MontaVista 2015

Licensed under the GPL
 
WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA RUN AT YOUR OWN RISK!

This README has

    1. Test suite contents
    2. Steps to execute tests
    3. Sample test results
    4. Log file information.


1. Test Suite Contents:
-----------------------
This test suite has two different test units kerntest and ntptest and they have to be executed independently.

a. kerntest:
						The objective here is to test how linux kernel handles leapsecond insertion/deletion. This test suite tests leapsecond insertion/deletion in linux Kernel using adjtimex call. It has 3 levels of testing.

         i. Basic Leap Second insertion/deletion: leapbasic is a test
            that uses adjtimex call to test basic leap second insertion
            deletion. It also has the capability to check if the kernel
            flag for LS insertion/deletion is set.
        ii. Leap second deadlock detection: This test checks for any
            leapsecond deadlock that is possible and reported to LKML
            last time when it was introduced.
       iii. Leap stress: leapstress is a stress test that inserts and
            deletes leapsecond simultaenously and check how Linux kernel
            handles it. In parallel, we also run various workloads/stress
            such as bonnie++(FS stress), hackbench (scheduler stress),
            Futex Stress, Cyclictest (RealTime stress). Leap second
            insertion/deletion is checked when these workloads are runnig
            and we test if there is any hrtimer expiry, futex deadlocks,
            or any kind of kernel panic/oops, lockups being observed.

b. ntptest:
						The objective here is to test if NTP server is able to propagate the LS flag to all NTP clients (running on various MV platforms) and further test if the respective NTP client is able to pass on the LS flag to Linux kernel. Also we simualte variuos workloads mentioned above and see if any issue is being observed in either NTP daemon or in Linux kernel. We also try to capture the ntp daemon statistics for users to analyse the offset and jitter, if any. Please note that we also try to capture CPU usage at the end of test after stopping all the workloads. The CPU usage should be similar to before the start of the test. There were some 100% CPU usage/spikes reported by various users during the previousleap second insertion. Ensure that no spikes are seen in CPU usage.

2. Steps to run tests:
----------------------

ALL TESTS need to be run as ROOT user.

General steps:

            1. Copy the leapsecondtest.tgz to all targets (machines)
               which needs to be test for leap second
            2. Untar the leapsecondtest.tgz to any location

Kerntest:

           a. cd leapsecondtest
           b. Run ./setup.sh (Resolve any issues here). The following messages should be displayed
               "kernel test tools build complete" 
               "futex stress tool build complete"
           c. cd kerntest
           d. Run ./testkernleap.sh 

All 3 tests mentioned above should pass here. All the logs will be available under kerntest/logs/

ntptest:
					npttest has two parts. One is server and client. The server part will configure a local NTP server with leap-seconds.list and custom ntp configuration. This local server will be responsible for passing on the LS flag to all NTP clients.
PLEASE NOTE: Choose an NTP server which doesn't need to be tested for Leap second issue. This server will act only like an local NTP server.

            Server Steps:
                a. cd leapsecondtest
                b. Run ./ntpserver_setup.sh


            Client Steps: (Targets/nodes under test)
                a. cd leapsecondtest
                b. Run ./setup.sh (Resolve any issues here). The following
                    messages should be displayed
                    "kernel test tools build complete" 
                    "futex stress tool build complete"
                c. cd ntptest
                d. Run ./testntpleap.sh <ntpserver_ip>

All the logs will be available under ntptest/logs/. Also the mpstat output that will be displayed at the end, should show the cpu usage. Please verify manually if the CPU usage is similar to before the start of the test.


3. Test Results/Sample test result :
------------------------------------

kerntest:

    ****************************************************
    1. Testing for basic leap second insertion/deletion
    ****************************************************
        a. Executing leapsecond insertion basic test
            [PASSED]: kernel leap second flag set to add
            [LOG] sleeping for 15 seconds...
            [PASSED]: Leap second inserted in kernel
        b. Executing leapsecond deletion basic test
            [PASSED]: kernel leap second flag set to del
            [LOG] Sleeping for 15 seconds...
            [PASSED]: Leap second deleted in kernel

    Basic leap second insertion/deletion test completed

    ***************************************************
    2. Testing for leapsecond deadlock
    ***************************************************
    Leap second deadlock detection test completed


    ***************************************************
    3. Testing for leapsecond stress
    ***************************************************
        [LOG] Starting futexstress
        [LOG] Starting cyclictest
        [LOG] Starting hackbench
        [LOG] Starting bonnie++
        [LOG] Sleeping for 5 mins
        [LOG] Executing leapstress for 10 iterations each for 10s
        [LOG] Checking dmesg for leap second ins/del 5 times each
        [PASSED]: hrtimer expiry not detected
        [LOG] cleanup complete
        [LOG] Leap stress logs available at logs/leapstress.log
        [PASSED]: Leap second stress

    Kernel leap second test complete

ntptest:

    ***************************************************
    Testing for leap second insertion through NTP
    ***************************************************
        [LOG] Sleeping for 30min for ntpclock to sync with server
        [PASSED]: Leap flag enabled in ntp client
        [LOG] Starting futexstress
        [LOG] Starting cyclictest
        [LOG] Starting hackbench
        [LOG] Starting bonnie++
        [LOG] Sleeping for 40mins....
        [PASSED]: Leap second inserted in kernel
        [LOG] Check for any hike in cpu usage...
			************************************************************************************************
			Linux 3.10.65.cge-rt68-preempt__ll_performance (Thresher)   07/01/15    _mips64_    (4 CPU)
			00:11:19     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
			00:11:19     all    1.51    0.00    4.34    0.91    0.00    0.30    0.00    0.00    0.00   92.94
			00:11:19       0    0.55    0.01    6.15    1.09    0.00    1.19    0.00    0.00    0.00   91.01
			00:11:19       1    1.62    0.00    3.72    0.84    0.00    0.00    0.00    0.00    0.00   93.82
			00:11:19       2    2.24    0.00    3.84    0.98    0.00    0.00    0.00    0.00    0.00   92.94
			00:11:19       3    1.64    0.00    3.64    0.75    0.00    0.00    0.00    0.00    0.00   93.97
			*************************************************************************************************
			[LOG] cleanup complete

NTP leap second test completed

4. Log file information:
------------------------

The logs for {kerntest, ntptest}/logs. The logs files are

        a. bonnie.log 
        b. futexstress.log
        c. leapstress.log (kerntest logs)
        d. cyclictest.log
        e. hackbench.log
        f. testkernleap.log (kerntest logs)
        g. testntpleap.log (ntptest logs)
