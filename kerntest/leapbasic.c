/***********************************************************
 * leapbasic.c - Add/delete Leap second in linux kernel
 *         by: Prem Karat (pkarat@mvista.com)
 *              (C) Copyright MontaVista Software, LLC 2015
 *              Licensed under the GPLv2
 * NOTE:
 * This program is derived from sls.c from 
 * https://github.com/AmadeusITGroup/NTP-Proxy/
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   WARNING: THIS WILL LIKELY HARDHANG SYSTEMS AND MAY LOSE DATA
 *   RUN AT YOUR OWN RISK!
 *
 * Original Author: robertkarbowski
 * This program (sls.c) is modified with following changes
 *         a. The default time is changed to 120 seconds instead of 600
 *            to suit the test execution needs and reduce the test exec
 *            time
 *         b. Also it has a fix to the bug reported here
 *            https://github.com/AmadeusITGroup/NTP-Proxy/issues/7
 *         c. Some cosmetic changes for pretty looking code :-)
 */


#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <sys/timex.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <strings.h>
#include <sys/types.h>
#include <getopt.h>


/* Number of seconds before midnight */
time_t bmidnight=120; 
/* Insert leap second */
int ls=STA_INS;
/* Print LS status only */
bool STATUS=false;    
/* Max number of digits for delay (incl. trailing null byte) */
#define NRLENGTH 10   

/* Print usage message */
void usage() {
	printf("Usage: leapbasic [[[-d seconds] [-l add|del]] | [-s] | [-h]]\n");
	printf("-d delay before leap second operation. Default 120s \n");
	printf("-l add: insert leap sec, del: delete leap sec. Default add\n");
	printf("-s leap second flag status\n");
	printf("-h display this help\n");
}

/* clear time state before calling insertion or deletion */
void clear_time_state(void) {
    struct timex tx;
    int ret;
    tx.modes = ADJ_STATUS;
    tx.status = STA_PLL;
    ret = adjtimex(&tx);

    tx.modes = ADJ_STATUS;
    tx.status = 0;
    ret = adjtimex(&tx);
}

/*  Print Leap Second flag status */
void pstatus() {
    struct timex tx;
    tx.modes=0;
    if(adjtimex(&tx) == -1) {
        perror("adjtimex(2)");
        exit(1);
    }
    printf("Kernel leap second flag: ");
    if(tx.status & STA_INS)
        printf("add\n");
    else if (tx.status & STA_DEL)
        printf("delete\n"); 
    else
        printf("not set\n");
}

/* Parse parameters */
void pparam(int argc, char** argv) {
	int opt;
	char strndelay[NRLENGTH];
	bool RMOD=false;
	static struct option longopts[]= {
 		{"delay",      required_argument, NULL, 'd'},
 		{"leapsecond", required_argument, NULL, 'l'},
 		{"status",     no_argument,       NULL, 's'},
 		{"help",       no_argument,       NULL, 'h'},
 		{0, 0, 0, 0}
	};
	while((opt=getopt_long(argc, argv, "d:l:sh", longopts, NULL)) != -1) {
 		switch(opt) {
 			case 'd':
  				RMOD=true;
  				sscanf(optarg, "%ld", &bmidnight);
  				bmidnight=abs(bmidnight);
  				snprintf(strndelay, NRLENGTH, "%ld", bmidnight);
  				if(strcmp(optarg, strndelay) != 0)  {
					memset(strndelay, '9', NRLENGTH-1);
					strndelay[NRLENGTH-1]=0;
   					printf("Wrong argument for option \'-d\' "
                           "range [0-%s]\n", strndelay);
   				    usage();
   				    exit(1);
  				}
  				break;
 			case 'l':
  				RMOD=true;
  				if(strncmp(optarg, "add", 3) == 0) {
   					ls=STA_INS;
   					break;
   				}
  				if(strncmp(optarg, "del", 3) == 0) {
   					ls=STA_DEL;
   					break;
   				}
  				printf("Wrong arg for option \'-l\'\n");
  				usage();
  				exit(1);
  				break;
 			case 's': // LS flag status only
  				STATUS=true;
  				break;
 			case 'h':
 			default:
  				usage();
  				exit(1);
 			}
	}
	if(STATUS && RMOD) {
 		printf("Options -l/-d and -s are mutually exclusive\n\n");
 		usage();
 		exit(1);
	}
}


int main(int argc, char** argv) {
	struct timeval tv;
	struct timex tx;
    /* Parse parameters */
    pparam(argc, argv);
    /* Print leap second flag status and exit */
    if(STATUS) {
        pstatus();
        exit(0);
    }
    // Check if caller is root
    if(getuid() != 0) {
        printf("Only \'root\' may modify OS parameters\n");
        printf("Everyone can use \'-s\' option\n\n");
        usage();
        exit(1);
    }
    /* Current time */
    gettimeofday(&tv, NULL);
    /* Next leap seconda*/
    tv.tv_sec +=86400 - tv.tv_sec % 86400;
    /* Set the time to be 'bmidnight' seconds before midnight */
    tv.tv_sec -=bmidnight;
    settimeofday(&tv, NULL);
    /* clear time state before setting flag */
    clear_time_state();
    /* Set leap second flag */
    tx.modes=ADJ_STATUS;
    tx.status=ls;
    if(adjtimex(&tx) == -1) {
        perror("Error: STA_INS/STA_DEL not set");
        exit(1);
    }
    pstatus();
    exit(0);
}
