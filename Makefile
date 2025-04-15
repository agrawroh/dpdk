################################################################################
# Monolithic Makefile for Modern DPDK (Unofficial) with 'install' target
################################################################################

# 1) Toolchain commands (override via environment if needed)
CC      ?= gcc
AR      ?= ar
LD      ?= ld
PREFIX  ?= /usr/local   # Used by 'make install'. Overridden by rules_foreign_cc.

# 2) Basic CFLAGS
CFLAGS  ?= -O3 -g -fPIC -Wall -Werror
# 3) Additional DPDK-specific flags or defines
DPDK_CFLAGS ?= -Wno-deprecated-declarations -D_GNU_SOURCE
# 4) Include paths (adjust to your layout)
INCLUDES  ?= -I$(CURDIR)/include -I$(CURDIR)

# 5) Libraries required at link time (adjust as needed)
LDLIBS   ?= -lm -lpthread -ldl

# 6) Final static library name
TARGET_LIB ?= libdpdk.a

# 7) Gather all .c files under lib/ and drivers/, excluding test/doc/examples
C_SRCS = $(shell find lib drivers -type f -name '*.c' \
          ! -path '*/test/*' \
          ! -path '*/doc/*' \
          ! -path '*/examples/*')

OBJS = $(C_SRCS:.c=.o)

################################################################################
# Top-level targets
################################################################################

.PHONY: all clean config install

all: config $(TARGET_LIB)

# Optional config step
config:
	@echo ">> No real config. If needed, generate rte_config.h or detect CPU features."

$(TARGET_LIB): $(OBJS)
	@echo "  [AR] $@"
	$(AR) rcs $@ $^

################################################################################
# Object file compilation
################################################################################

%.o: %.c
	@echo "  [CC] $<"
	$(CC) $(CFLAGS) $(DPDK_CFLAGS) $(INCLUDES) -c $< -o $@

################################################################################
# install
################################################################################
# We install headers with a structure that supports the simple include style
# (#include <rte_*.h>) while ensuring all necessary headers are available.

install: all
	@echo ">> Installing to $(PREFIX)"
	
	# Create required directories
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	
	# Install static library
	cp -f $(TARGET_LIB) $(PREFIX)/lib
	
	# Install config headers
	if [ -f config/rte_config.h ]; then \
		cp -f config/rte_config.h $(PREFIX)/include/; \
	fi
	
	# Copy all critical DPDK header files directly to the include directory
	# This flattens the hierarchy for simple includes
	@echo ">> Copying header files from lib/ directories..."
	find lib -name "*.h" | while read header; do \
		cp -f $$header $(PREFIX)/include/; \
	done
	
	# Copy kernel-specific headers that are needed for sys/queue.h and other system headers
	if [ -d lib/eal/windows/include/sys ]; then \
		mkdir -p $(PREFIX)/include/sys; \
		cp -f lib/eal/windows/include/sys/* $(PREFIX)/include/sys/; \
	fi
	
	if [ -d lib/eal/windows/include/netinet ]; then \
		mkdir -p $(PREFIX)/include/netinet; \
		cp -f lib/eal/windows/include/netinet/* $(PREFIX)/include/netinet/; \
	fi
	
	# Install driver-specific headers that might be needed
	@echo ">> Copying essential driver headers..."
	for header in $(shell find drivers -name "*.h" | grep -E '(pmd|rte_|public)'); do \
		cp -f $$header $(PREFIX)/include/; \
	done
	
	# Create a special verification for the required headers mentioned in the error logs
	@echo ">> Verifying critical headers..."
	for header in rte_config.h rte_eal.h rte_ethdev.h rte_mbuf.h rte_version.h; do \
		if [ ! -f $(PREFIX)/include/$$header ]; then \
			echo "WARNING: Critical header $$header missing! Finding and copying..."; \
			find . -name $$header -type f | head -1 | xargs -I{} cp {} $(PREFIX)/include/ || echo "ERROR: Could not find $$header!"; \
		else \
			echo "✓ Found $$header"; \
		fi \
	done
	
	@echo ">> Installation complete"

################################################################################
# cleanup
################################################################################

clean:
	rm -f $(OBJS) $(TARGET_LIB)
