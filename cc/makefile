# Makefile
#

INSTALL_PATH = /usr/local

# For SCO
CFLAGS = -b elf -O -D_SVID

# For IRIX
CFLAGS = -xansi -fullwarn -O3 -g0

# For Solaris
CFLAGS = -fast -xO4 -s -v -Xa

# For HPUX
CFLAGS = -Wall -O -Ae

# For OSF1
CFLAGS = -w -verbose -fast -std1 -g0

# For GNU C compiler
CFLAGS = -Wall # -O6 -pedantic

#SHELL = /bin/sh

akb_ccFLAGS = -v -T # Add -T option to allow binary to be traceable

akb_cc: akb_cc.c
	$(CC) $(CFLAGS) $@.c -o $@
clean:
	rm -f *.o *~ *.x.c akb_cc *.x
