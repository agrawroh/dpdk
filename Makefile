################################################################################
# Monolithic Makefile for Modern DPDK (Unofficial, Example Only)
################################################################################

# 1) Toolchain commands (override via environment if needed)
CC      ?= gcc
AR      ?= ar
LD      ?= ld

# 2) Basic CFLAGS
#    Tweak as needed for your environment, CPU type, and warnings
CFLAGS  ?= -O3 -g -fPIC -Wall -Werror
# 3) Additional DPDK-specific flags or defines
#    Add things like -mavx2, -march=native, or -DRTE_XXXX if needed.
DPDK_CFLAGS ?= -Wno-deprecated-declarations -D_GNU_SOURCE
# 4) Include paths
#    Adjust according to where your DPDK headers live.
INCLUDES  ?= -I$(CURDIR) -I$(CURDIR)/include

# 5) Libraries required at link time. 
#    You may need -lnuma, -lrt, -lpcap, or others depending on your drivers.
LDLIBS   ?= -lm -lpthread -ldl

# 6) If you want to produce a static library, specify it here:
TARGET_LIB ?= libdpdk.a

# 7) Gather all .c files under lib/ and drivers/, excluding test, doc, or example code
C_SRCS = $(shell find lib drivers -type f -name '*.c' \
          ! -path '*/test/*' \
          ! -path '*/doc/*' \
          ! -path '*/examples/*')

# 8) Convert each .c file into a corresponding .o object file
OBJS = $(C_SRCS:.c=.o)

################################################################################
# Top-level build targets
################################################################################

.PHONY: all clean config

all: config $(TARGET_LIB)

# Optional "config" step (placeholder). In older DPDK builds, you’d generate
# config headers or detect CPU flags. Here it just prints a note:
config:
	@echo ">> No real config. If needed, generate rte_config.h or detect CPU features."

# Build the static library from all .o files
$(TARGET_LIB): $(OBJS)
	@echo "  [AR] $@"
	$(AR) rcs $@ $^

################################################################################
# Object file compilation rules
################################################################################

%.o: %.c
	@echo "  [CC] $<"
	$(CC) $(CFLAGS) $(DPDK_CFLAGS) $(INCLUDES) -c $< -o $@

################################################################################
# Cleanup
################################################################################

clean:
	rm -f $(OBJS) $(TARGET_LIB)
