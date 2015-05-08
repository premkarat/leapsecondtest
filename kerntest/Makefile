CC=gcc
.PHONY: all leapbasic leaptimer leapstress clean
all: leapbasic leapcrash leapstress

leapbasic: leapbasic.c
	$(CC) -o $@ $< -ldl
leapcrash: leapcrash.c
	$(CC) -o $@ $< -lrt
leapstress: leapstress.c
	$(CC) -o $@ $< -lrt

clean:
	rm -f leapbasic leapcrash leapstress
