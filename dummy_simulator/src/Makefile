CC=$(CROSS_COMPILE)gcc
RM=rm

OBJECTS=main.o fpga.o worker.o calib.o fpga_awg.o generate.o fpga_pid.o pid.o fpga_dummy.o dummy.o

CFLAGS+= -Wall -Werror -g -fPIC $(INCLUDE)
LDFLAGS=-shared

CONTROLLER     = ../controllerhf.so
CONTROLLER_DBG = ../controllerhf_dbg.so
CONTROLLER_RLD = ../controllerhf_rld.so

all: $(CONTROLLER)

$(CONTROLLER): $(OBJECTS)
	$(CC) -o $(CONTROLLER) $(OBJECTS) $(CFLAGS) $(LDFLAGS)
	-$(RM) -f $(OBJECTS)

$(CONTROLLER_DBG): $(OBJECTS)
	sed 's?/* *#define DEBUG 1.*?#define DEBUG 1? ' -i main.h
	$(CC) -o $(CONTROLLER_DBG) $(OBJECTS) $(CFLAGS) $(LDFLAGS)
	-$(RM) -f $(OBJECTS)
	sed 's?/* *#define DEBUG 1.*?// #define DEBUG 1? ' -i main.h

$(CONTROLLER_RLD): $(OBJECTS)
	sed "s?/\\*RELOAD_DOCK_START\\*/.*/\\*RELOAD_DOCK_END\\*/?/*RELOAD_DOCK_START*/ PARAMS_DUMMY_PARAMS - 1 /*RELOAD_DOCK_END*/?"  -i main.c
	$(CC) -o $(CONTROLLER_RLD) $(OBJECTS) $(CFLAGS) $(LDFLAGS)
	-$(RM) -f $(OBJECTS)
	sed "s?/\\*RELOAD_DOCK_START\\*/.*/\\*RELOAD_DOCK_END\\*/?/*RELOAD_DOCK_START*/ PARAMS_NUM /*RELOAD_DOCK_END*/?"  -i main.c

clean:
	-$(RM) -f $(OBJECTS)
