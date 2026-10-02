CC=$(CROSS_COMPILE)gcc
RM=rm

OBJECTS=main.o fpga.o worker.o calib.o fpga_awg.o generate.o fpga_pid.o pid.o fpga_dummy.o dummy.o

CFLAGS+= -Wall -Werror -g -fPIC $(INCLUDE)
# -lm: main.c/worker.c use round/ceil/sqrt...; -lpthread: worker thread and mutexes (explicit, so that
# controllerhf.so does not depend on the libraries the server happens to have loaded)
LDFLAGS=-shared -lm -lpthread

CONTROLLER     = ../controllerhf.so

# controllerhf_dbg.so / controllerhf_rld.so are built by ../Makefile (sed on main.h / main.c before compiling).
# The old rules here ran the sed after compiling the objects, so the three .so were identical.

all: $(CONTROLLER)

$(CONTROLLER): $(OBJECTS)
	$(CC) -o $(CONTROLLER) $(OBJECTS) $(CFLAGS) $(LDFLAGS)
	-$(RM) -f $(OBJECTS)

clean:
	-$(RM) -f $(OBJECTS)
