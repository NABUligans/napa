#include ../../libsrc/Make.config

CC = zcc

COMPILER ?= sccz80
CFLAGS = 	+nabu -lm -lndos -create-app \
			-DAMALLOC -DNODELAY \
			-pragma-define:CLIB_RXBUF_SIZE=1024 \
    		-pragma-define:CLIB_TXBUF_SIZE=256 \
    		-pragma-redirect:CRT_FONT=_font
EXECFILES = $(CFILES:.c=.NABU)

ifeq ($(COMPILER),sdcc)
   CFLAGS += -compiler=sdcc -SO3 --max-allocs-per-node200000 --fsigned-char 
all: test launcher
else
   CFLAGS += 
all: $(EXECFILES) test launcher
endif

test: test.c
	$(CC) $(CFLAGS) font.asm test.c -otest.bin

launcher: main.c
	$(CC) $(CFLAGS) font.asm main.c -olauncher.bin

clean:
	$(RM) *.obj *.sym *.map *.o* *.bin zcc_opt.def *.reloc *.NABU
