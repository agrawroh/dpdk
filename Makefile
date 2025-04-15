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
# We copy:
#   - The static library to $(PREFIX)/lib
#   - All headers from all relevant locations to $(PREFIX)/include

install: all
	@echo ">> Installing to $(PREFIX)"
	
	# Create required directories
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	
	# Install static library
	cp -f $(TARGET_LIB) $(PREFIX)/lib
	
	# Copy top-level include/ directory if it exists
	if [ -d include ]; then \
	  cp -R include/* $(PREFIX)/include/; \
	fi
	
	# Copy config headers
	if [ -d config ]; then \
	  cp -f config/rte_config.h $(PREFIX)/include/; \
	fi
	
	# Find and copy all header files from lib/ directories
	@echo ">> Copying header files from lib/ directories..."
	find lib -type f -name "*.h" | while read header; do \
		install -D -m 644 $$header $(PREFIX)/include/$$(basename $$header); \
	done
	
	# Find and copy all header files from drivers/ directories that might be needed
	@echo ">> Copying header files from drivers/ directories..."
	find drivers -type f -name "*.h" | grep -v "/test/" | grep -v "/doc/" | while read header; do \
		install -D -m 644 $$header $(PREFIX)/include/$$(basename $$header); \
	done
	
	# Ensure key headers are present (the ones needed by Envoy)
	@echo ">> Checking for key headers..."
	for header in rte_config.h rte_eal.h rte_ethdev.h rte_mbuf.h rte_version.h; do \
		if [ ! -f $(PREFIX)/include/$$header ]; then \
			echo "WARNING: Key header $$header not found. Manually locating and copying..."; \
			find . -name $$header -type f | head -1 | xargs -I{} cp {} $(PREFIX)/include/ || echo "ERROR: Could not find $$header!"; \
		fi \
	done
	
	@echo ">> Installation complete"

################################################################################
# cleanup
################################################################################

clean:
	rm -f $(OBJS) $(TARGET_LIB)
