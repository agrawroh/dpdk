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
# We install all headers from nested directories to a flat include structure

install: all
	@echo ">> Installing to $(PREFIX)"
	
	# Create required directories
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	mkdir -p $(PREFIX)/include/sys
	mkdir -p $(PREFIX)/include/netinet
	
	# Install static library
	cp -f $(TARGET_LIB) $(PREFIX)/lib
	
	# Copy config headers
	@echo ">> Copying config headers..."
	if [ -f config/rte_config.h ]; then \
		cp -f config/rte_config.h $(PREFIX)/include/; \
	fi
	
	# Copy ALL header files from lib directory and subdirectories
	@echo ">> Copying all lib headers..."
	find lib -type f -name "*.h" | while read header; do \
		cp -f $$header $(PREFIX)/include/; \
	done
	
	# Copy ALL header files from drivers directory and subdirectories
	@echo ">> Copying all driver headers..."
	find drivers -type f -name "*.h" | while read header; do \
		cp -f $$header $(PREFIX)/include/; \
	done
	
	# Copy ALL header files from any other directories that might contain headers
	@echo ">> Copying any remaining headers..."
	find . -type f -name "*.h" \
		! -path "./lib/*" \
		! -path "./drivers/*" \
		! -path "./config/*" \
		! -path "./test/*" \
		! -path "./doc/*" \
		! -path "./examples/*" \
		| while read header; do \
		cp -f $$header $(PREFIX)/include/; \
	done
	
	# Copy system headers for compatibility
	@echo ">> Copying system compatibility headers..."
	# For sys/queue.h and other system headers
	find . -path "*/include/sys/*.h" | while read header; do \
		cp -f $$header $(PREFIX)/include/sys/; \
	done
	
	# For netinet headers
	find . -path "*/include/netinet/*.h" | while read header; do \
		cp -f $$header $(PREFIX)/include/netinet/; \
	done
	
	# Verify critical headers exist
	@echo ">> Verifying critical headers..."
	for header in rte_config.h rte_eal.h rte_ethdev.h rte_mbuf.h rte_version.h; do \
		if [ ! -f $(PREFIX)/include/$$header ]; then \
			echo "WARNING: Critical header $$header not found in flat include. Finding and copying..."; \
			find . -name $$header -type f | head -1 | xargs -I{} cp {} $(PREFIX)/include/ || echo "ERROR: Could not find $$header!"; \
		else \
			echo "✓ Found $$header"; \
		fi \
	done
	
	# Check if there are any filename collisions and warn
	@echo ">> Checking for filename collisions..."
	duplicates=$$(find $(PREFIX)/include -type f -name "*.h" | xargs basename -a | sort | uniq -d); \
	if [ -n "$$duplicates" ]; then \
		echo "WARNING: The following filenames appear multiple times and may have been overwritten:"; \
		echo "$$duplicates"; \
		echo "Only the last copied version of each file will be used."; \
	fi
	
	@echo ">> Installation complete"
	@echo ">> Total headers installed: $$(find $(PREFIX)/include -type f -name "*.h" | wc -l)"

################################################################################
# cleanup
################################################################################

clean:
	rm -f $(OBJS) $(TARGET_LIB)
